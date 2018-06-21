require 'test_helper'

class Arask::Test < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "truth" do
    assert_kind_of Module, Arask
  end

  test 'sets correct execute_at and queues the next job' do
    assert(Arask.respond_to? :setup)

    assert_no_enqueued_jobs

    # Stop time (Yes I am God)
    travel_to Time.current


    assert_enqueued_with at: 2.minutes.from_now do
      Arask.setup do |arask|
        arask.create script: 'random', interval: 2.minutes
      end
      assert(Arask::AraskJob.first.execute_at == 2.minutes.from_now)
      assert_enqueued_jobs 1
    end

    Arask.setup do |arask|
      arask.create script: 'random2"', interval: 10.hours
    end
    assert(Arask::AraskJob.first.execute_at == 10.hours.from_now)

    Arask.setup do |arask|
      arask.create script: 'random3', interval: 5.days
    end
    assert(Arask::AraskJob.first.execute_at == 5.days.from_now)
  end

  test 'maximum wait time is 5 minutes' do
    travel_to Time.current
    assert_enqueued_with at: 5.minutes.from_now do
      Arask.setup do |arask|
        arask.create script: 'random"', interval: :daily
      end
    end
  end
end