class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :objetivos, dependent: :destroy
  has_many :atividades, through: :objetivos
  has_many :registros, through: :atividades
end
