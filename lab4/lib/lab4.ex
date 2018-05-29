defmodule Lab4.Email do
    import Bamboo.Email

    @from "no-reply@myapp.com"

    def make_email(to \\ "alexburlacu96@gmail.com",
                   body \\ "Thanks for joining!") do
        new_email(
            to: to,
            from: @from,
            subject: "Welcome to the app.",
            text_body: body
          )      
    end

    def send_email() do
        Lab4.Email.make_email
        |> Lab4.Mailer.deliver_now
    end
end
