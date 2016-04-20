require 'telegram/bot'
require 'fallen'
require_relative '../config/environment'

# require 'net/http'
class TelegramInlineBot

  BOOKMATE_HOST = 'https://bookmate.com'.freeze
  TOKEN = 'PASTE_YOUR_TOKEN'.freeze #
  DEFAULT_RESULTS_QUANTITY = 5.freeze

  def process_message(message)
    "Hello, #{message.from.first_name}! For now I can process only inline queries, sorry for that"
  end

  def process_inline_query(message)
    query_text = message.query

    if query_text && query_text != ''
      return prepare_answer_query(query_text)
    else
      return default_answer_query
    end

  end

  def prepare_answer_query(query_text)
    form # here's a way to get books list, it's project specific hence I veil this
    books = form.books.to_a
    results = []
    i = 0

    if books.empty?
      results = default_answer_query
    else
      books.each do |book|
        results[i] =
          Telegram::Bot::Types::InlineQueryResultArticle.new(
            id: book.uuid,
            title: book.title,
            description: book.authors,
            thumb_url: book.cover_url.blank? ? '' : BOOKMATE_HOST + book.cover_url,
            input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
              message_text:
              "<b>#{book.title}</b>
  <a href='#{prepare_book_url(book)}'>On Bookmate</a>
  Author: #{book.authors}",
              parse_mode: 'HTML'))
      i += 1
      end
    end

    results
  end

  def default_answer_query
    books # some default popular results, also project specific
    results = []
    i = 0

    unless books.empty?
      books.each do |book|
        results[i] =
          Telegram::Bot::Types::InlineQueryResultArticle.new(
            id: book.uuid,
            title: book.title,
            description: book.authors,
            thumb_url: book.cover_url.blank? ? '' : BOOKMATE_HOST + book.cover_url,
            input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
              message_text:
              "<b>#{book.title}</b>
  <a href='#{prepare_book_url(book)}'>On Bookmate</a>
  Author: #{book.authors}",
              parse_mode: 'HTML'))
      i += 1
      end
    end

    results
  end

  def prepare_book_url(book)
    BOOKMATE_HOST + '/books/' + book.uuid
  end

  def main
    Telegram::Bot::Client.run(TOKEN) do |bot|
        bot.listen do |message|

          case message
          when Telegram::Bot::Types::Message
            puts "Message @#{message.from.username}: #{message.text}"

            # create a button to come back to the previously active chat
            kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Switch to inline', switch_inline_query: 'Hello I\'m awesome')]
            markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
            bot.api.send_message(chat_id: message.chat.id, text: process_message(message), reply_markup: markup)
          when Telegram::Bot::Types::InlineQuery
            puts "InlineQuery @#{message.from.username}: #{message.query} and #{message.id}"

            # inline results
            results = process_inline_query(message)
            if results.empty?
              puts bot.api.answer_inline_query(inline_query_id: message.id, results: results, switch_pm_text: 'Switch to PM', cache_time: 1)
            else
              puts bot.api.answer_inline_query(inline_query_id: message.id, results: results, cache_time: 1)
            end
          end
      end
    end
  end
end

# easy hack to daemonize bot, sorry for that
module Azazel
  extend Fallen

  def self.run
    while running?
      bot = TelegramInlineBot.new
      bot.main
    end
  end
end

Azazel.daemonize!
Azazel.start!
