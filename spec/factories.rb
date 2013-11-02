FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"
      
    factory :admin do
      admin true
    end
    
    factory :reset do
      password_reset_token "something"
      password_reset_sent_at { 1.hour.ago }
    end
    
    factory :reset_expire do
      password_reset_token "something"
      password_reset_sent_at { 5.hour.ago }
    end
  end
    
  factory :micropost do
    content "Lorem ipsum"
    user
  end
end
        