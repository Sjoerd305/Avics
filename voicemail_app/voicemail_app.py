import imaplib
import email
import time
import os
import speech_recognition as sr
from telegram import Bot
from telegram.error import TelegramError

# Email retrieval configuration
IMAP_SERVER = "imap.gmail.com"
IMAP_PORT = 993
EMAIL = "testkaas45@gmail.com"  # Your Gmail email address
PASSWORD = "hhwnxzivauhomalh"  # An app-specific password for Gmail

# Telegram configuration
TELEGRAM_TOKEN = "6532702050:AAHd5wkCZi7B57NCwlP_hnq9ZVdVaw_cKlM"
CHAT_ID = "-776033090"

def convert_speech_to_text(audio_content):
    recognizer = sr.Recognizer()
    audio = sr.AudioData(audio_content, sample_rate=16000, sample_width=2)  # Adjust sample rate and width as needed

    try:
        text = recognizer.recognize_sphinx(audio)
        return text
    except sr.UnknownValueError:
        return "Could not understand audio"
    except sr.RequestError as e:
        return f"Error in recognizing the audio: {e}"

def send_telegram_message(text):
    try:
        bot = Bot(token=TELEGRAM_TOKEN)
        bot.send_message(chat_id=CHAT_ID, text=text)
    except TelegramError as e:
        print("TelegramError:", e)

def main():
    while True:
        try:
            # Connect to the IMAP server
            mail = imaplib.IMAP4_SSL(IMAP_SERVER, IMAP_PORT)
            mail.login(EMAIL, PASSWORD)
            mail.select("inbox")

            # Search for unseen emails with attachments
            result, data = mail.search(None, "UNSEEN")
            email_ids = data[0].split()

            for email_id in email_ids:
                result, email_data = mail.fetch(email_id, "(RFC822)")
                raw_email = email_data[0][1]
                msg = email.message_from_bytes(raw_email)

                for part in msg.walk():
                    if part.get_content_type() == "audio/wav":
                        audio_content = part.get_payload(decode=True)
                        text = convert_speech_to_text(audio_content)
                        send_telegram_message(text)

            # Mark processed emails as seen
            for email_id in email_ids:
                mail.store(email_id, "+FLAGS", "\\Seen")

            print("Processed new emails. Waiting for new messages...")
        except Exception as e:
            print("An error occurred:", e)

        # Wait for a specific interval before checking again
        time.sleep(60)  # Wait for 60 seconds before checking again

if __name__ == "__main__":
    main()