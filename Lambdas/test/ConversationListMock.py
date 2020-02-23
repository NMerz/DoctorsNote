import json
import random


def lambda_handler(event, context):
    toReturn = '{"conversationList":[{"conversationID": ' + str(random.randint(1,19)) + ',"converserID": ' + str(random.randint(1,19)) + ',"unreadMessages": "false","lastMessageTime": 1582475039543}]}'
    return json.loads(toReturn)


