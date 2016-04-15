require 'telegram/bot'
# require 'net/http'

token = '150509464:AAHp-hAiYCqJIGJ7l9PJZLDKu_GWgDQX26E'.freeze
default_results_quantity = 5.freeze

def processMessage(message)
  return "Hello, #{message.from.first_name}! For now I can process only inline queries, sorry for that"
end

def processInlineQuery(message)
  inlineQuery = message
  queryId = message.id
  queryText = message.query
    
  if queryText && queryText != ""
    return prepareAnswerQuery(queryText)
  else
    return defaultAnswerQuery
  end 

end

def prepareAnswerQuery(queryText)
  f = "" # BookSuggestsForm.new({query: queryText, pp: default_results_quantity})
  
  if f
    results = defaultAnswerQuery
  else
    for i in 0..default_results_quantity
      unless f
        results[i] = [
          Telegram::Bot::Types::InlineQueryResultArticle.new(
            id: i,
            title: "Cool title",
            input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: "hey looool")),
          Telegram::Bot::Types::InlineQueryResultArticle.new(
            id: i,
            title: "Cool title 2",
            input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: "hey looool 2")) ]
      end
    end
  end

  return results
end

def defaultAnswerQuery
  return results = [
    Telegram::Bot::Types::InlineQueryResultArticle.new(
      id: 1,
      title: "Cool title",
      input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: "hey looool")),
    Telegram::Bot::Types::InlineQueryResultArticle.new(
      id: 2,
      title: "Cool title 2",
      input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: "hey looool 2")) ]
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|

    case message
    when Telegram::Bot::Types::Message
      puts "Message @#{message.from.username}: #{message.text}"

      bot.api.send_message(chat_id: message.chat.id, text: processMessage(message) )
    when Telegram::Bot::Types::InlineQuery
      puts " InlineQuery @#{message.from.username}: #{message.query} and #{message.id}"
      
      puts bot.api.answer_inline_query(inline_query_id: message.id, results: processInlineQuery(message), cache_time: 86400)
      # puts bot.api.answer_inline_query(inline_query_id: message.id, results: results.to_a, cache_time: 86400)
    end

  end
end
