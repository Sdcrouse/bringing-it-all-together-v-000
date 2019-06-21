class Dog 
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name 
    @breed = breed
  end
  
  def self.create_table 
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
      
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def save 
    if self.id 
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      
      DB[:conn].execute(sql, self.name, self.breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM DOGS")[0][0]
    end
    
    self
  end
  
  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?" 
    # I could say LIMIT 1, but I shouldn't have to since ids are supposed to be unique.
    
    row = DB[:conn].execute(sql, id)[0]
    
    self.new_from_db(row)
  end
  
  def self.find_or_create_by(name:, breed:)
    select_dog_sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    
    found_dog = DB[:conn].execute(select_dog_sql, name, breed)
    
    if found_dog.empty?
      self.create(name: name, breed: breed)
    else 
      self.new_from_db(found_dog[0])
    end
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    
    row = DB[:conn].execute(sql, name)[0]
    
    self.new_from_db(row)
  end
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end