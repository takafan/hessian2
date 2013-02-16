class Monkey
  attr_accessor :name, 
    :age, 
    :description,
    :icon, 
    :appears_in, 
    :unlocked_at, 
    :parent,
    :cost_btd1,
    :cost_btd2_easy,
    :cost_btd2_medium,
    :cost_btd2_hard,
    :cost_btd3_easy,
    :cost_btd3_medium,
    :cost_btd3_hard,
    :cost_btd4_easy,
    :cost_btd4_medium,
    :cost_btd4_hard,
    :cost_btd4ios_easy,
    :cost_btd4ios_medium,
    :cost_btd4ios_hard,
    :cost_btd5_easy,
    :cost_btd5_medium,
    :cost_btd5_hard,
    :cost_btd5ios_easy,
    :cost_btd5ios_medium,
    :cost_btd5ios_hard,
    :sell_btd1,
    :sell_btd2_easy,
    :sell_btd2_medium,
    :sell_btd2_hard,
    :sell_btd3_easy,
    :sell_btd3_medium,
    :sell_btd3_hard,
    :sell_btd4_easy,
    :sell_btd4_medium,
    :sell_btd4_hard,
    :sell_btd4ios_easy,
    :sell_btd4ios_medium,
    :sell_btd4ios_hard,
    :sell_btd5_easy,
    :sell_btd5_medium,
    :sell_btd5_hard,
    :sell_btd5ios_easy,
    :sell_btd5ios_medium,
    :sell_btd5ios_hard

  def self.generate(count = 10_000)
    [].tap do |arr|
      count.times do |i| 
        arr << Monkey.new(name: "Dart#{i}",
          age: i,
          description: nil,
          icon: "Dart#{i}.png",
          appears_in: ["BTD#{i}"],
          unlocked_at: 'N/A',
          parent: nil,
          cost_btd1: 250,
          cost_btd2_easy: 250,
          cost_btd2_medium: 280,
          cost_btd2_hard: 285,
          cost_btd3_easy: 215,
          cost_btd3_medium: 255,
          cost_btd3_hard: 270,
          cost_btd4_easy: 170,
          cost_btd4_medium: 200,
          cost_btd4_hard: 215,
          cost_btd4ios_easy: 215,
          cost_btd4ios_medium: 250,
          cost_btd4ios_hard: 265,
          cost_btd5_easy: 170,
          cost_btd5_medium: 200,
          cost_btd5_hard: 215,
          cost_btd5ios_easy: 170,
          cost_btd5ios_medium: 200,
          cost_btd5ios_hard: 215,
          sell_btd1: 250,
          sell_btd2_easy: 250,
          sell_btd2_medium: 280,
          sell_btd2_hard: 285,
          sell_btd3_easy: 215,
          sell_btd3_medium: 255,
          sell_btd3_hard: 270,
          sell_btd4_easy: 170,
          sell_btd4_medium: 200,
          sell_btd4_hard: 215,
          sell_btd4ios_easy: 215,
          sell_btd4ios_medium: 250,
          sell_btd4ios_hard: 265,
          sell_btd5_easy: 170,
          sell_btd5_medium: 200,
          sell_btd5_hard: 215,
          sell_btd5ios_easy: 170,
          sell_btd5ios_medium: 200,
          sell_btd5ios_hard: 215
        )
      end
    end
  end

  def self.generate_hash(count = 10_000)
    [].tap do |arr|
      count.times do |i| 
        arr << { name: "Dart#{i}",
          age: i,
          description: nil,
          icon: "Dart#{i}.png",
          appears_in: ["BTD#{i}"],
          unlocked_at: 'N/A',
          parent: nil,
          cost_btd1: 250,
          cost_btd2_easy: 250,
          cost_btd2_medium: 280,
          cost_btd2_hard: 285,
          cost_btd3_easy: 215,
          cost_btd3_medium: 255,
          cost_btd3_hard: 270,
          cost_btd4_easy: 170,
          cost_btd4_medium: 200,
          cost_btd4_hard: 215,
          cost_btd4ios_easy: 215,
          cost_btd4ios_medium: 250,
          cost_btd4ios_hard: 265,
          cost_btd5_easy: 170,
          cost_btd5_medium: 200,
          cost_btd5_hard: 215,
          cost_btd5ios_easy: 170,
          cost_btd5ios_medium: 200,
          cost_btd5ios_hard: 215,
          sell_btd1: 250,
          sell_btd2_easy: 250,
          sell_btd2_medium: 280,
          sell_btd2_hard: 285,
          sell_btd3_easy: 215,
          sell_btd3_medium: 255,
          sell_btd3_hard: 270,
          sell_btd4_easy: 170,
          sell_btd4_medium: 200,
          sell_btd4_hard: 215,
          sell_btd4ios_easy: 215,
          sell_btd4ios_medium: 250,
          sell_btd4ios_hard: 265,
          sell_btd5_easy: 170,
          sell_btd5_medium: 200,
          sell_btd5_hard: 215,
          sell_btd5ios_easy: 170,
          sell_btd5ios_medium: 200,
          sell_btd5ios_hard: 215
        }
      end
    end
  end

  def initialize(attrs = {})
    attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    # attrs.each { |k, v| instance_variable_set("@#{k}", v) if respond_to?("@#{k}") }
    
  end

  def [](k)
    self.instance_variable_get("@#{k.to_s}")
  end

end
