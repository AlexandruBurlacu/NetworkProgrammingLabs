defmodule Lab4.Login do

  def login (username, password) do
    Application.put_env :mailbox, "SMTP_USERNAME", username
    Application.put_env :mailbox, "SMTP_PASSWORD", password
  end

end
