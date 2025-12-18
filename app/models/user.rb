class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :habitos, dependent: :destroy
  has_many :registros, through: :habitos
  has_many :tags, dependent: :destroy

  # Callbacks
  after_create :start_trial

  # Subscription methods

  # Verifica se o usuário está em período de trial
  def on_trial?
    trial_ends_at.present? && trial_ends_at > Time.current
  end

  # Verifica se o usuário tem acesso premium (pago ou em trial)
  def premium?
    premium == true || on_trial?
  end

  # Verifica se pode criar mais hábitos
  def can_create_habito?
    premium? || habitos.count < 4
  end

  # Retorna quantos hábitos restam (para usuários free)
  def habitos_remaining
    return "Ilimitado" if premium?

    remaining = 4 - habitos.count
    remaining > 0 ? remaining : 0
  end

  # Retorna o número de dias restantes no trial
  def trial_days_remaining
    return 0 unless on_trial?

    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  # Verifica se o trial está próximo do fim (últimos 2 dias)
  def trial_ending_soon?
    on_trial? && trial_days_remaining <= 2
  end

  private

  # Inicia o período de trial de 7 dias ao criar usuário
  def start_trial
    update(trial_ends_at: 7.days.from_now)
  end
end
