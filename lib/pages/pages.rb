require 'discordrb'
require 'pp'

module PagesExceptions
  class CannotPaginate < StandardError; end
end

class Pages
  def initialize(bot, message, entries, per_page=12, emojis=nil, numbered=true, embed={})
    @bot = bot
    @entries = entries
    @message = message
    @channel = @message.channel
    @author = message.author
    @per_page = per_page
    pages, left_over = @entries.length.divmod(@per_page)
    pages += 1 if left_over
    @maximum_pages = pages
    @embed = Discordrb::Webhooks::Embed.new embed
    @paginating = entries.length > per_page
    @reaction_emojis = emojis ? emojis : [
        ['⏮', 'first_page'],
        ['◀', 'previous_page'],
        ['▶', 'next_page'],
        ['⏭', 'last_page'],
        # ["\u23F9\uFE0F".encode('utf-8'), 'numbered_page'],
        ['⏹', 'stop_pages'],
        ['ℹ', 'show_help'],
    ]

    server = @channel.server
    @permissions = {}
    [:add_reaction, :embed_links].each do |perm|
      if server
        bot_profile = @bot.profile.on(server)
        @permissions[perm] = bot_profile.permission?(perm, @message.channel)
      else
        @permissions[perm]
      end
    end

    # raise PagesExceptions::CannotPaginate, 'Bot does not have embed links permission.' unless @permissions[:embed_links]
  end

  def get_page(page)
    base = (page - 1) * @per_page
    @entries[base..(base+@per_page)-1]
  end

  def show_page(page, *, first: false)
    @current_page = page
    entries = get_page(page)
    p = @numbered ? entries.each.with_index((page-1) * @per_page).map { |t| "#{t}. #{t}" % t} : entries
    @embed.footer = { text: 'Page %s/%s (%s entries)' % [page, @maximum_pages, @entries.length] }

    unless @paginating
      @embed.description = p.join("\n")
      @channel.send_embed '', @embed
      return
    end

    unless first
      @embed.description = p.join("\n")
      @message.edit '', embed = @embed
      return
    end

    # raise CannotPaginate 'Bot does not have add reactions permission.' unless @permissions[:add_reactions]
    # raise CannotPaginate 'Bot does not have Read Message History permission.' unless @permissions[:read_message_history]

    @embed.footer[:text] += "\nConfused? React with :information_source: for more info."
    @embed.description = p.join("\n")
    @message = @channel.send_embed '', @embed
    @reaction_emojis.each do |reaction, _|
      unless @maximum_pages == 2 && ['\u23ed', '\u23ee'].include?(reaction)
        @message.react(reaction)
      end
    end
  end

  def checked_show_page(page)
    show_page(page) if page != 0 and page <= @maximum_pages
  end

  def first_page
    show_page(1)
  end

  def last_page
    show_page(@maximum_pages)
  end

  def next_page
    checked_show_page(@current_page + 1)
  end

  def previous_page
    checked_show_page(@current_page - 1)
  end

  def show_current_page
    show_page(@current_page) if @paginating
  end

  def numbered_page
    to_delete = []
    # STUB
  end

  def show_help
    # STUB
    'help'
  end

  def stop_pages
    @embed.footer = { text: 'No longer paginating.' }
    @message.edit '', embed = @embed
    @paginating = false
  end

  def react_check(reaction, user)
    return false if user == nil || user.id != @author.id

    @reaction_emojis.each do |emoji, func|
      if reaction.name == emoji
        @match = func
        return true
      end
    end
    return false
  end

  def paginate
    show_page(1, first: true)

    while @paginating
      @bot.add_await :react, Discordrb::Events::ReactionEvent do |await|
        reaction = react_check(await.emoji, await.user)
        eval @match if reaction
      end
    end
  end
end