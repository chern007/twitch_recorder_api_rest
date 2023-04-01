from ast import For
from turtle import width
import requests, json, smtplib, ssl, getpass, sys


class Email:

    def __init__(self):
        self.my_email = "carloshernandezcrespo@gmail.com"
        self.my_pass = "XXXXXXXXXXXXXXX"

    def sendEmail(self, to_email, subject, body):
        smtp_obj = smtplib.SMTP("smtp.gmail.com", 587)
        smtp_obj.ehlo()
        smtp_obj.starttls()
        smtp_obj.login(self.my_email, self.my_pass)

        email_from_address = self.my_email
        email_to_address = to_email

        headers = ["From: " + email_from_address,
                    "Subject: " + subject,
                    "To: " + email_to_address,
                    "MIME-Version: 1.0",
                    "Content-Type: text/plain"]
        headers = "\r\n".join(headers)
        smtp_obj.sendmail(email_from_address, email_to_address, (headers + "\r\n\r\n" +  body).encode())

        smtp_obj.quit()
        print("INFO: The email was sent.")


if __name__ == '__main__':

    email = Email()

    try:
        res = requests.get('http://localhost:4040/api/tunnels')
        res = json.loads(res.content)

        url=res['tunnels'][0]['public_url']
        
        email.sendEmail("carloshernandezcrespo@gmail.com","INFO: ngrok public URL", url)

    except Exception as ex:
        error_msg = ex.args[0]
        print(error_msg)
        email.sendEmail("carloshernandezcrespo@gmail.com","ERROR: ngrok public URL", error_msg)