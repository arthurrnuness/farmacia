class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :habitos, dependent: :destroy
  has_many :registros, through: :habitos
  has_many :tags, dependent: :destroy
end
