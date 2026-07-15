import imaplib
import email
from email.header import decode_header

def read_emails(imap_server, email_user, email_password, folder='INBOX'):
    """
    Reads emails from a specified IMAP folder.
    """
    try:
        # Connect to the server
        mail = imaplib.IMAP4_SSL(imap_server)
        
        # Login to your account
        mail.login(email_user, email_password)
        print(f"Successfully logged in to {imap_server}")

        # Select the folder you want to read
        mail.select(folder)

        # Search for all emails
        # 'ALL' searches for all messages in the mailbox
        status, messages = mail.search(None, 'ALL')
        
        if status != 'OK':
            print("No messages found or error occurred during search.")
            return

        # Get the list of email IDs
        mail_ids = messages[0].split()
        print(f"Found {len(mail_ids)} emails.")

        # Iterate through the last 5 emails (to avoid overwhelming output)
        for i in mail_ids[-5:]:
            # Fetch the email data by ID
            status, msg_data = mail.fetch(i, '(RFC822)')
            
            for response_part in msg_data:
                if isinstance(response_part, tuple):
                    # Parse the raw bytes into an email object
                    msg = email.message_from_bytes(response_part[1])
                    
                    # Decode the email subject
                    subject, encoding = decode_header(msg["Subject"])[0]
                    if isinstance(subject, bytes):
                        subject = subject.decode(encoding if encoding else "utf-8")
                    
                    # Decode the email from
                    from_address, encoding = decode_header(msg["From"])[0]
                    if isinstance(from_address, bytes):
                        from_address = from_address.decode(encoding if encoding else "utf-8")

                    print(f"\n--- Email ID: {i.decode()} ---")
                    print(f"Subject: {subject}")
                    print(f"From:    {from_address}")

                    # If the email is multipart, iterate through parts to find the body
                    if msg.is_multipart():
                        for part in msg.walk():
                            content_type = part.get_content_type()
                            content_disposition = str(part.get("Content-Disposition"))

                            if content_type == "text/plain" and "attachment" not in content_disposition:
                                body = part.get_payload(decode=True).decode()
                                print(f"Body: {body[:100]}...") # Print first 100 chars
                                break
                    else:
                        # If it's a single part email
                        body = msg.get_payload(decode=True).decode()
                        print(f"Body: {body[:100]}...")

        # Close the connection
        mail.close()
        mail.logout()
        print("\nConnection closed.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # CONFIGURATION - Replace these with your actual details
    # For Gmail: imap.gmail.com
    # For Outlook: outlook.office365.com
    IMAP_SERVER = 'imap.gmail.com' 
    EMAIL_USER = 'your_email@gmail.com'
    EMAIL_PASSWORD = 'your_app_password' # Use an App Password, NOT your main password

    read_emails(IMAP_SERVER, EMAIL_USER, EMAIL_PASSWORD)
