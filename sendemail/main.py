"""My simple python test for sending emails with google."""


def send_email_ip(user, pwd, recipient, subject, body):
    import smtplib
    import logging

    FROM = user
    TO = recipient if isinstance(recipient, list) else [recipient]
    SUBJECT = subject
    TEXT = body

    # Prepare actual message
    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (
        FROM,
        ", ".join(TO),
        SUBJECT,
        TEXT,
    )
    try:
        # server = smtplib.SMTP("smtp.gmail.com", 587)
        server = smtplib.SMTP("smtp-relay.gmail.com", 587)
        # server.ehlo('mike@desupervised.io')
        server.ehlo()
        # server.starttls()
        # server.login(user, pwd)
        server.sendmail(FROM, TO, message)
        server.close()
        print("successfully sent the mail")
    except Exception as e:
        print("failed to send mail")
        logging.error(traceback.format_exc())


def send_email(user, pwd, sender, recipient, subject, body):
    """Sends an email to a recipient using Gsuite SMTP."""
    import smtplib
    import logging

    FROM = sender
    TO = recipient if isinstance(recipient, list) else [recipient]
    SUBJECT = subject
    TEXT = body

    # Prepare actual message
    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (
        FROM,
        ", ".join(TO),
        SUBJECT,
        TEXT,
    )
    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        # server = smtplib.SMTP("smtp-relay.gmail.com", 587)
        server.ehlo()
        server.starttls()
        server.login(user, pwd)
        server.sendmail(FROM, TO, message)
        server.close()
        print("successfully sent the mail")
    except Exception as e:
        print("failed to send mail")
        logging.error(traceback.format_exc())


send_email(
    "mike@desupervised.io",
    "somethingsecret",
    "noreply@desupervised.io",
    "micke.green@gmail.com",
    "Hi Mike",
    "I just wanted to say hello to you.",
)
