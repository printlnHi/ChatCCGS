from apns2.client import APNsClient
from apns2.payload import Payload

client = APNsClient("APNSChatCCGSCertificate.p12",use_sandbox = False, use_alternative_port=False)

def sendPushNotification(APNSToken, alert, badge):
    global client
    payload = Payload(alert = alert,sound = "default",badge = badge)
    topic = "au.edu.wa.ccgs.MarcusHandley.NPA.ChatCCGS"
    client.send_notification(APNSToken, payload, topic)

sendPushNotifcation("24a7f0a19d0ec45fadf33644bcfafc2c2d3783dac357247bfd78c80239493612", "testing",1)
