class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    new_dog = self.new(name: hash[:name], breed: hash[:breed])
    new_dog.save
  end

  def self.find_by_id(num)
    sql = 'SELECT * FROM dogs WHERE id = ?'
    result = DB[:conn].execute(sql, num)[0]
    self.new(name: result[1], breed: result[2], id: result[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE (name = ?, breed = ?)"
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = self.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      hash = {name: name, breed: breed}
      dog = self.create(hash)
    end
    dog
  end

end
