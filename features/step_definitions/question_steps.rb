# coding: utf-8

Given /^there are different questions$/ do
  questionZero  = Fabricate(:question, :title => 'Question with zero answers', :group => @group)
  questionOne   = Fabricate(:question, :title => 'Question with one answer', :group => @group, :votes_average => 1, :votes_count => 1, :answers_count => 1, :views_count => 1)
  questionFew   = Fabricate(:question, :title => 'Question with few answers', :group => @group, :votes_average => 2, :votes_count => 2, :answers_count => 3, :views_count => 24)
  questionMany  = Fabricate(:question, :title => 'Question with many answers', :group => @group, :votes_average => 5, :votes_count => 5, :answers_count => 13, :views_count => 55)
end

When /^I visit root page$/ do
  visit('http://www.meltdown.pl.local/')
end

When /^I visit questions page$/ do
  visit('http://www.meltdown.pl.local/pytania')
end

Then /^I should see valid counters with correct pluralization$/ do
  def few_or_many(count)
    type = nil
    if count.abs == 1
      type = :one
    elsif [2, 3, 4].include?(count.abs % 10) && ![12, 13, 14].include?(count.abs % 100)
      type = :few
    else
      type = :many
    end
    type
  end

  vote_counters = page.all('div.votecount')
  answer_counters = page.all('div.answercount-none') + page.all('div.answercount')
  view_counters = page.all('div.viewcount')

  # Yeap, not really DRY in here.
  # TODO: Refactor checking counters

  vote_counters.each do |counter|
    value = counter.find('div.count').text.to_i
    label = counter.find('div.tail')

    case few_or_many(value)
      when :one
        label.should have_content('głos')
      when :few
        label.should have_content('głosy')
      when :many
        label.should have_content('głosów')
    end
  end

  answer_counters.each do |counter|
    value = counter.find('div.count').text.to_i
    label = counter.find('div.tail')

    case few_or_many(value)
      when :one
        label.should have_content('odpowiedź')
      when :few
        label.should have_content('odpowiedzi')
      when :many
        label.should have_content('odpowiedzi')
    end
  end

  view_counters.each do |counter|
    value = counter.find('div.count').text.to_i
    label = counter.find('div.tail')

    case few_or_many(value)
      when :one
        label.should have_content('wyświetlenie')
      when :few
        label.should have_content('wyświetlenia')
      when :many
        label.should have_content('wyświetleń')
    end
  end
end

