from apns2.client import APNsClient
from apns2.payload import Payload

client = APNsClient("APNSChatCCGSCertificate.p12",use_sandbox = False, use_alternative_port=False)

'''def sendPushNotification(APNSToken, alert, badge):
    global client
    payload = Payload(alert = alert,sound = "default",badge = 1)
    topic = "au.edu.wa.ccgs.MarcusHandley.NPA.ChatCCGS"
    client.send_notification(APNSToken, payload, topic)
'''
