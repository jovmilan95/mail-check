# Mail Check
The script sends a test email from a sender account to a receiver account and then checks if the email has been successfully delivered. It uses SMTP for sending emails and IMAP for receiving emails. The script also includes a retry logic for checking the email delivery, and it throws an exception if the email is not delivered after a specified number of attempts.

#### Script Parameters

1. **ReceiverAccount**:
   - Description: Email address of the recipient to whom test emails will be sent.
   - Default value: 'tmailping@knowit.rs'.

2. **ReceiverPassword**:
   - Description: Password for logging into the recipient's email account.
   - **Mandatory parameter**.

3. **ImapServer**:
   - Description: IMAP server address for receiving emails.
   - Default value: 'imap.knowit.rs'.

4. **ImapPort**:
   - Description: Port of the IMAP server.
   - Default value: 993.

5. **SenderAccount**:
   - Description: Email address of the sender for sending test emails.
   - Default value: 'monitoring@tmail.trezor.gov.rs'.

6. **SenderPassword**:
   - Description: Password for logging into the sender's email account.
   - **Mandatory parameter**.

7. **SmtpServer**:
   - Description: SMTP server address for sending emails.
   - Default value: 'tmail.trezor.gov.rs'.

8. **SmtpPort**:
   - Description: Port of the SMTP server.
   - Default value: 25.

9. **MaxAttempts**:
   - Description: Maximum number of attempts to check if the sent email has been delivered.
   - Default value: 10.

10. **DelaySeconds**:
    - Description: Time in seconds to wait between attempts to check if the email has been delivered.
    - Default value: 3.
