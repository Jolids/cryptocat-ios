//
//  TBOTREncryption.m
//  TBOTRWrapper
//
//  Created by Thomas Balthazar on 25/09/13.
//  Copyright (c) 2013 Thomas Balthazar. All rights reserved.
//

#import "TBOTREncryption.h"

#import "proto.h"
#import "context.h"
#import "message.h"
#import "privkey.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface TBOTREncryption ()

+ (void)generatePrivateKeyForAccount:(NSString *)account protocol:(NSString *)protocol;
+ (NSString *)documentsDirectory;
+ (NSString *)privateKeyPath;
- (ConnContext *)contextForUsername:(NSString *)username
                        accountName:(NSString *)accountName
                           protocol:(NSString *) protocol;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TBOTREncryption

static TBOTREncryption *sharedOTREncryption = nil;
static OtrlUserState otr_userstate = NULL;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark OtrlMessageAppOps

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Return the OTR policy for the given context.
 */
static OtrlPolicy policy_cb(void *opdata, ConnContext *context) {
  NSLog(@"policy_cb");
  return OTRL_POLICY_DEFAULT;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Generate a private key for the given accountname/protocol
 */
static void create_privkey_cb(void *opdata, const char *accountname, const char *protocol) {
  NSLog(@"create_privkey_cb");
  NSString *privateKeyPath = [TBOTREncryption privateKeyPath];
  const char *privateKeyPathC = [privateKeyPath cStringUsingEncoding:NSUTF8StringEncoding];
  
  otrl_privkey_generate(otr_userstate, privateKeyPathC, accountname, protocol);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Report whether you think the given user is online.  Return 1 if
 * you think he is, 0 if you think he isn't, -1 if you're not sure.
 *
 * If you return 1, messages such as heartbeats or other
 * notifications may be sent to the user, which could result in "not
 * logged in" errors if you're wrong. 
 */
// TODO: implement this function
static int is_logged_in_cb(void *opdata, const char *accountname,
                           const char *protocol, const char *recipient) {
  NSLog(@"is_logged_in_cb");
	return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Send the given IM to the given recipient from the given
 * accountname/protocol.$
 */
// TODO: implement this function
static void inject_message_cb(void *opdata, const char *accountname,
                              const char *protocol, const char *recipient, const char *message) {
  NSLog(@"inject_message_cb");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* Display a notification message for a particular accountname /
 * protocol / username conversation.
 */
// TODO: implement this function
static void update_context_list_cb(void *opdata) {
  NSLog(@"update_context_list_cb");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * A new fingerprint for the given user has been received.
 */
static void confirm_fingerprint_received_cb(void *opdata, OtrlUserState us,
                                            const char *accountname, const char *protocol,
                                            const char *username, unsigned char fingerprint[20]) {
  NSLog(@"confirm_fingerprint_received_cb");
  char our_hash[45], their_hash[45];
  
  // TODO: check if I cannot find the context using the obj-c method i wrote
  ConnContext *context = otrl_context_find(otr_userstate, username, accountname, protocol,
                                           OTRL_INSTAG_BEST, NO, NULL, NULL, NULL);
  if (!context) return;
  
  otrl_privkey_fingerprint(otr_userstate, our_hash, context->accountname, context->protocol);
  otrl_privkey_hash_to_human(their_hash, fingerprint);
  
  // TODO: implement this function
  /*
  OTRKit *otrKit = [OTRKit sharedInstance];
  if (otrKit.delegate && [otrKit.delegate respondsToSelector:@selector(showFingerprintConfirmationForAccountName:protocol:userName:theirHash:ourHash:)]) {
    [otrKit.delegate showFingerprintConfirmationForAccountName:[NSString stringWithUTF8String:accountname] protocol:[NSString stringWithUTF8String:protocol] userName:[NSString stringWithUTF8String:username] theirHash:[NSString stringWithUTF8String:their_hash] ourHash:[NSString stringWithUTF8String:our_hash]];
  }
  */
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * The list of known fingerprints has changed.  Write them to disk.
 */
// TODO: implement this function
static void write_fingerprints_cb(void *opdata) {
  NSLog(@"write_fingerprints_cb");
  /*
  OTRKit *otrKit = [OTRKit sharedInstance];
  if (otrKit.delegate && [otrKit.delegate respondsToSelector:@selector(writeFingerprints)]) {
    [otrKit.delegate writeFingerprints];
  } else {
    FILE *storef;
    NSString *path = [otrKit fingerprintsPath];
    storef = fopen([path UTF8String], "wb");
    if (!storef) return;
    otrl_privkey_write_fingerprints_FILEp(userState, storef);
    fclose(storef);
  }
  */
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * A ConnContext has entered a secure state.
 */
// TODO: implement this function
static void gone_secure_cb(void *opdata, ConnContext *context) {
  NSLog(@"gone_secure_cb");
//  OTRKit *otrKit = [OTRKit sharedInstance];
//  [otrKit updateEncryptionStatusWithContext:context];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * A ConnContext has left a secure state. 
 */
// TODO: implement this function
static void gone_insecure_cb(void *opdata, ConnContext *context) {
  NSLog(@"gone_insecure_cb");
//  OTRKit *otrKit = [OTRKit sharedInstance];
//  [otrKit updateEncryptionStatusWithContext:context];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * We have completed an authentication, using the D-H keys we
 * already knew.  is_reply indicates whether we initiated the AKE.
 */
// TODO: implement this function
static void still_secure_cb(void *opdata, ConnContext *context, int is_reply) {
  NSLog(@"still_secure_cb");
//  OTRKit *otrKit = [OTRKit sharedInstance];
//  [otrKit updateEncryptionStatusWithContext:context];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Find the maximum message size supported by this protocol.
 */
// TODO: implement this function
static int max_message_size_cb(void *opdata, ConnContext *context) {
  NSLog(@"max_message_size_cb");
  return 0;
  
  /*Although the maximum message size depends on a number of factors, we
   found experimentally that the following rough values based solely on the
   (pidgin) protocol name work well:
   "prpl-msn",   1409
   "prpl-icq",   2346
   "prpl-aim",   2343
   "prpl-yahoo", 832
   "prpl-gg",    1999
   "prpl-irc",   417
   "prpl-oscar", 2343
   */
  /*void* lookup_result = g_hash_table_lookup(mms_table, context->protocol);
   if (!lookup_result)
   return 0;
   else
   return *((int*)lookup_result);*/
  
//  OTRKit *otrKit = [OTRKit sharedInstance];
//  if (otrKit.delegate && [otrKit.delegate respondsToSelector:@selector(maxMessageSizeForProtocol:)]) {
//    return [otrKit.delegate maxMessageSizeForProtocol:[NSString stringWithUTF8String:context->protocol]];
//  }
//  
//  if(context->protocol)
//  {
//    NSString *protocol = [NSString stringWithUTF8String:context->protocol];
//    
//    if([protocol isEqualToString:@"prpl-oscar"])
//      return 2343;
//  }
//  return 0;
  
// adium
//  AIChat *chat = chatForContext(context);
//  
//  /* Values from http://www.cypherpunks.ca/otr/UPGRADING-libotr-3.1.0.txt */
//  static NSDictionary *maxSizeByServiceClassDict = nil;
//  if (!maxSizeByServiceClassDict) {
//    maxSizeByServiceClassDict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                 [NSNumber numberWithInteger:2343], @"AIM-compatible",
//                                 [NSNumber numberWithInteger:1409], @"MSN",
//                                 [NSNumber numberWithInteger:832], @"Yahoo!",
//                                 [NSNumber numberWithInteger:1999], @"Gadu-Gadu",
//                                 [NSNumber numberWithInteger:417], @"IRC",
//                                 nil];
//  }
//  
//  /* This will return 0 if we don't know (unknown protocol) or don't need it (Jabber),
//   * which will disable fragmentation.
//   */
//  int ret = [[maxSizeByServiceClassDict objectForKey:chat.account.service.serviceClass] intValue];
//  
//  return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Return a newly allocated string containing a human-friendly
 * representation for the given account
 */
// TODO: implement this function
static const char *account_display_name_cb(void *opdata, const char *accountname,
                                           const char *protocol) {
  NSLog(@"account_display_name_cb");
//  const char *ret = strdup([[accountFromAccountID(accountname) formattedUID] UTF8String]);
//  return ret;
  return "foo";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Deallocate a string returned by account_name
 */
// TODO: implement this function
static void account_display_name_free_cb(void *opdata, const char *account_display_name) {
  NSLog(@"account_display_name_free_cb");
	if (account_display_name)
		free((char *)account_display_name);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/*
 * We received a request from the buddy to use the current "extra"
 * symmetric key.  The key will be passed in symkey, of length
 * OTRL_EXTRAKEY_BYTES.  The requested use, as well as use-specific
 * data will be passed so that the applications can communicate other
 * information (some id for the data transfer, for example).
 */
// TODO: implement this function
static void received_symkey_cb(void *opdata, ConnContext *context,
                               unsigned int use, const unsigned char *usedata,
                               size_t usedatalen, const unsigned char *symkey) {
  NSLog(@"received_symkey_cb");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* Return a string according to the error event. This string will then
 * be concatenated to an OTR header to produce an OTR protocol error
 * message. The following are the possible error events:
 * - OTRL_ERRCODE_ENCRYPTION_ERROR
 * 		occured while encrypting a message
 * - OTRL_ERRCODE_MSG_NOT_IN_PRIVATE
 * 		sent encrypted message to somebody who is not in
 * 		a mutual OTR session
 * - OTRL_ERRCODE_MSG_UNREADABLE
 *		sent an unreadable encrypted message
 * - OTRL_ERRCODE_MSG_MALFORMED
 * 		message sent is malformed */
static const char* otr_error_message_cb(void *opdata, ConnContext *context,
                                        OtrlErrorCode err_code) {
  NSLog(@"otr_error_message_cb");
  NSString *errorString = nil;
  switch (err_code)
  {
    case OTRL_ERRCODE_NONE :
      break;
    case OTRL_ERRCODE_ENCRYPTION_ERROR :
      errorString = @"Error occurred encrypting message.";
      break;
    case OTRL_ERRCODE_MSG_NOT_IN_PRIVATE :
      if (context) {
        errorString = [NSString stringWithFormat:
                       @"You sent encrypted data to %s, who wasn't expecting it.",
                       context->accountname];
      }
      break;
    case OTRL_ERRCODE_MSG_UNREADABLE :
      errorString = @"You transmitted an unreadable encrypted message.";
      break;
    case OTRL_ERRCODE_MSG_MALFORMED :
      errorString = @"You transmitted a malformed data message.";
      break;
  }
  return [errorString UTF8String];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Deallocate a string returned by otr_error_message
 */
// TODO: implement this function
static void otr_error_message_free_cb(void *opdata, const char *err_msg) {
  NSLog(@"otr_error_message_free_cb");
  // Leak memory here instead of crashing:
  // if (err_msg) free((char*)err_msg);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Return a string that will be prefixed to any resent message. If this
 * function is not provided by the application then the default prefix,
 * "[resent]", will be used.
 */
// TODO: implement this function
static const char *resent_msg_prefix_cb(void *opdata, ConnContext *context) {
  NSLog(@"resent_msg_prefix_cb");
  NSString *resentString = @"[resent]";
	return [resentString UTF8String];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Deallocate a string returned by resent_msg_prefix 
 */
// TODO: implement this function
static void resent_msg_prefix_free_cb(void *opdata, const char *prefix) {
  NSLog(@"resent_msg_prefix_free_cb");
  // Leak memory here instead of crashing:
	// if (prefix) free((char*)prefix);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Update the authentication UI with respect to SMP events
 * These are the possible events:
 * - OTRL_SMPEVENT_ASK_FOR_SECRET
 *      prompt the user to enter a shared secret. The sender application
 *      should call otrl_message_initiate_smp, passing NULL as the question.
 *      When the receiver application resumes the SM protocol by calling
 *      otrl_message_respond_smp with the secret answer.
 * - OTRL_SMPEVENT_ASK_FOR_ANSWER
 *      (same as OTRL_SMPEVENT_ASK_FOR_SECRET but sender calls
 *      otrl_message_initiate_smp_q instead)
 * - OTRL_SMPEVENT_CHEATED
 *      abort the current auth and update the auth progress dialog
 *      with progress_percent. otrl_message_abort_smp should be called to
 *      stop the SM protocol.
 * - OTRL_SMPEVENT_INPROGRESS 	and
 *   OTRL_SMPEVENT_SUCCESS 		and
 *   OTRL_SMPEVENT_FAILURE    	and
 *   OTRL_SMPEVENT_ABORT
 *      update the auth progress dialog with progress_percent
 * - OTRL_SMPEVENT_ERROR
 *      (same as OTRL_SMPEVENT_CHEATED)
 */
// TODO: implement this function
static void handle_smp_event_cb(void *opdata, OtrlSMPEvent smp_event,
                                ConnContext *context, unsigned short progress_percent,
                                char *question) {
  NSLog(@"handle_smp_event_cb");
  /*
   if (!context) return;
   switch (smp_event)
   {
   case OTRL_SMPEVENT_NONE :
   break;
   case OTRL_SMPEVENT_ASK_FOR_SECRET :
   otrg_dialog_socialist_millionaires(context);
   break;
   case OTRL_SMPEVENT_ASK_FOR_ANSWER :
   otrg_dialog_socialist_millionaires_q(context, question);
   break;
   case OTRL_SMPEVENT_CHEATED :
   otrg_plugin_abort_smp(context);
   // FALLTHROUGH
   case OTRL_SMPEVENT_IN_PROGRESS :
   case OTRL_SMPEVENT_SUCCESS :
   case OTRL_SMPEVENT_FAILURE :
   case OTRL_SMPEVENT_ABORT :
   otrg_dialog_update_smp(context,
   smp_event, ((gdouble)progress_percent)/100.0);
   break;
   case OTRL_SMPEVENT_ERROR :
   otrg_plugin_abort_smp(context);
   break;
   }
   */
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* Handle and send the appropriate message(s) to the sender/recipient
 * depending on the message events. All the events only require an opdata,
 * the event, and the context. The message and err will be NULL except for
 * some events (see below). The possible events are:
 * - OTRL_MSGEVENT_ENCRYPTION_REQUIRED
 *      Our policy requires encryption but we are trying to send
 *      an unencrypted message out.
 * - OTRL_MSGEVENT_ENCRYPTION_ERROR
 *      An error occured while encrypting a message and the message
 *      was not sent.
 * - OTRL_MSGEVENT_CONNECTION_ENDED
 *      Message has not been sent because our buddy has ended the
 *      private conversation. We should either close the connection,
 *      or refresh it.
 * - OTRL_MSGEVENT_SETUP_ERROR
 *      A private conversation could not be set up. A gcry_error_t
 *      will be passed.
 * - OTRL_MSGEVENT_MSG_REFLECTED
 *      Received our own OTR messages.
 * - OTRL_MSGEVENT_MSG_RESENT
 *      The previous message was resent.
 * - OTRL_MSGEVENT_RCVDMSG_NOT_IN_PRIVATE
 *      Received an encrypted message but cannot read
 *      it because no private connection is established yet.
 * - OTRL_MSGEVENT_RCVDMSG_UNREADABLE
 *      Cannot read the received message.
 * - OTRL_MSGEVENT_RCVDMSG_MALFORMED
 *      The message received contains malformed data.
 * - OTRL_MSGEVENT_LOG_HEARTBEAT_RCVD
 *      Received a heartbeat.
 * - OTRL_MSGEVENT_LOG_HEARTBEAT_SENT
 *      Sent a heartbeat.
 * - OTRL_MSGEVENT_RCVDMSG_GENERAL_ERR
 *      Received a general OTR error. The argument 'message' will
 *      also be passed and it will contain the OTR error message.
 * - OTRL_MSGEVENT_RCVDMSG_UNENCRYPTED
 *      Received an unencrypted message. The argument 'smessage' will
 *      also be passed and it will contain the plaintext message.
 * - OTRL_MSGEVENT_RCVDMSG_UNRECOGNIZED
 *      Cannot recognize the type of OTR message received.
 * - OTRL_MSGEVENT_RCVDMSG_FOR_OTHER_INSTANCE
 *      Received and discarded a message intended for another instance.
 */
// TODO: implement this function
static void handle_msg_event_cb(void *opdata, OtrlMessageEvent msg_event,
                                ConnContext *context, const char* message, gcry_error_t err) {
  NSLog(@"handle_msg_event_cb");
  /*
   PurpleConversation *conv = NULL;
   gchar *buf;
   OtrlMessageEvent * last_msg_event;
   
   if (!context) return;
   
   conv = otrg_plugin_context_to_conv(context, 1);
   last_msg_event = g_hash_table_lookup(conv->data, "otr-last_msg_event");
   
   switch (msg_event)
   {
   case OTRL_MSGEVENT_NONE:
   break;
   case OTRL_MSGEVENT_ENCRYPTION_REQUIRED:
   buf = g_strdup_printf(_("You attempted to send an "
   "unencrypted message to %s"), context->username);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, _("Attempting to"
   " start a private conversation..."), 1, OTRL_NOTIFY_WARNING,
   _("OTR Policy Violation"), buf,
   _("Unencrypted messages to this recipient are "
   "not allowed.  Attempting to start a private "
   "conversation.\n\nYour message will be "
   "retransmitted when the private conversation "
   "starts."));
   g_free(buf);
   break;
   case OTRL_MSGEVENT_ENCRYPTION_ERROR:
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, _("An error occurred "
   "when encrypting your message.  The message was not sent."),
   1, OTRL_NOTIFY_ERROR, _("Error encrypting message"),
   _("An error occurred when encrypting your message"),
   _("The message was not sent."));
   break;
   case OTRL_MSGEVENT_CONNECTION_ENDED:
   buf = g_strdup_printf(_("%s has already closed his/her private "
   "connection to you"), context->username);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, _("Your message "
   "was not sent.  Either end your private conversation, "
   "or restart it."), 1, OTRL_NOTIFY_ERROR,
   _("Private connection closed"), buf,
   _("Your message was not sent.  Either close your "
   "private connection to him, or refresh it."));
   g_free(buf);
   break;
   case OTRL_MSGEVENT_SETUP_ERROR:
   if (!err) {
   err = GPG_ERR_INV_VALUE;
   }
   switch(gcry_err_code(err)) {
   case GPG_ERR_INV_VALUE:
   buf = g_strdup(_("Error setting up private "
   "conversation: Malformed message received"));
   break;
   default:
   buf = g_strdup_printf(_("Error setting up private "
   "conversation: %s"), gcry_strerror(err));
   break;
   }
   
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, buf, 1,
   OTRL_NOTIFY_ERROR, _("OTR Error"), buf, NULL);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_MSG_REFLECTED:
   display_otr_message_or_notify(opdata,
   context->accountname, context->protocol,
   context->username,
   _("We are receiving our own OTR messages.  "
   "You are either trying to talk to yourself, "
   "or someone is reflecting your messages back "
   "at you."), 1, OTRL_NOTIFY_ERROR,
   _("OTR Error"), _("We are receiving our own OTR messages."),
   _("You are either trying to talk to yourself, "
   "or someone is reflecting your messages back "
   "at you."));
   break;
   case OTRL_MSGEVENT_MSG_RESENT:
   buf = g_strdup_printf(_("<b>The last message to %s was resent."
   "</b>"), context->username);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, buf, 1,
   OTRL_NOTIFY_INFO, _("Message resent"), buf, NULL);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_RCVDMSG_NOT_IN_PRIVATE:
   buf = g_strdup_printf(_("<b>The encrypted message received from "
   "%s is unreadable, as you are not currently communicating "
   "privately.</b>"), context->username);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, buf, 1,
   OTRL_NOTIFY_INFO, _("Unreadable message"), buf, NULL);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_RCVDMSG_UNREADABLE:
   buf = g_strdup_printf(_("We received an unreadable "
   "encrypted message from %s."), context->username);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, buf, 1,
   OTRL_NOTIFY_ERROR, _("OTR Error"), buf, NULL);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_RCVDMSG_MALFORMED:
   buf = g_strdup_printf(_("We received a malformed data "
   "message from %s."), context->username);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, buf, 1,
   OTRL_NOTIFY_ERROR, _("OTR Error"), buf, NULL);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_LOG_HEARTBEAT_RCVD:
   buf = g_strdup_printf(_("Heartbeat received from %s.\n"),
   context->username);
   log_message(opdata, buf);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_LOG_HEARTBEAT_SENT:
   buf = g_strdup_printf(_("Heartbeat sent to %s.\n"),
   context->username);
   log_message(opdata, buf);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_RCVDMSG_GENERAL_ERR:
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, message, 1,
   OTRL_NOTIFY_ERROR, _("OTR Error"), message, NULL);
   break;
   case OTRL_MSGEVENT_RCVDMSG_UNENCRYPTED:
   buf = g_strdup_printf(_("<b>The following message received "
   "from %s was <i>not</i> encrypted: [</b>%s<b>]</b>"),
   context->username, message);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, buf, 1,
   OTRL_NOTIFY_INFO, _("Received unencrypted message"),
   buf, NULL);
   emit_msg_received(context, buf);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_RCVDMSG_UNRECOGNIZED:
   buf = g_strdup_printf(_("Unrecognized OTR message received "
   "from %s.\n"), context->username);
   log_message(opdata, buf);
   g_free(buf);
   break;
   case OTRL_MSGEVENT_RCVDMSG_FOR_OTHER_INSTANCE:
   if (*last_msg_event == msg_event) {
   break;
   }
   buf = g_strdup_printf(_("%s has sent a message intended for a "
   "different session. If you are logged in multiple times, "
   "another session may have received the message."),
   context->username);
   display_otr_message_or_notify(opdata, context->accountname,
   context->protocol, context->username, buf, 1,
   OTRL_NOTIFY_INFO, _("Received message for a different "
   "session"), buf, NULL);
   g_free(buf);
   break;
   }
   
   *last_msg_event = msg_event;
   */
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Create a instance tag for the given accountname/protocol if
 * desired. 
 */
// TODO: implement this function
static void create_instag_cb(void *opdata, const char *accountname, const char *protocol) {
//  OTRKit *otrKit = [OTRKit sharedInstance];
//  FILE *instagf;
//  NSString *path = [otrKit instanceTagsPath];
//  instagf = fopen([path UTF8String], "w+b");
//  otrl_instag_generate_FILEp(userState, instagf, accountname, protocol);
//  fclose(instagf);
  NSLog(@"create_instag_cb");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Called immediately before a data message is encrypted, and after a data
 * message is decrypted. The OtrlConvertType parameter has the value
 * OTRL_CONVERT_SENDING or OTRL_CONVERT_RECEIVING to differentiate these
 * cases. 
 */
// TODO: implement this function
static void convert_data_cb(void *opdata, ConnContext *context,
                           OtrlConvertType convert_type, char ** dest, const char *src) {
  NSLog(@"convert_data_cb");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 * Deallocate a string returned by convert_msg.
 */
// TODO: implement this function
static void convert_data_free_cb(void *opdata, ConnContext *context, char *dest) {
  NSLog(@"convert_data_free_cb");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/* When timer_control is called, turn off any existing periodic
 * timer.
 *
 * Additionally, if interval > 0, set a new periodic timer
 * to go off every interval seconds.  When that timer fires, you
 * must call otrl_message_poll(userstate, uiops, uiopdata); from the
 * main libotr thread.
 *
 * The timing does not have to be exact; this timer is used to
 * provide forward secrecy by cleaning up stale private state that
 * may otherwise stick around in memory.  Note that the
 * timer_control callback may be invoked from otrl_message_poll
 * itself, possibly to indicate that interval == 0 (that is, that
 * there's no more periodic work to be done at this time).
 *
 * If you set this callback to NULL, then you must ensure that your
 * application calls otrl_message_poll(userstate, uiops, uiopdata);
 * from the main libotr thread every definterval seconds (where
 * definterval can be obtained by calling
 * definterval = otrl_message_poll_get_default_interval(userstate);
 * right after creating the userstate).  The advantage of
 * implementing the timer_control callback is that the timer can be
 * turned on by libotr only when it's needed.
 *
 * It is not a problem (except for a minor performance hit) to call
 * otrl_message_poll more often than requested, whether
 * timer_control is implemented or not.
 *
 * If you fail to implement the timer_control callback, and also
 * fail to periodically call otrl_message_poll, then you open your
 * users to a possible forward secrecy violation: an attacker that
 * compromises the user's computer may be able to decrypt a handful
 * of long-past messages (the first messages of an OTR
 * conversation).
 */
// TODO: implement this function
static void timer_control_cb(void *opdata, unsigned int interval) {
//  OTRKit *otrKit = [OTRKit sharedInstance];
//  if (otrKit.pollTimer) {
//    [otrKit.pollTimer invalidate];
//    otrKit.pollTimer = nil;
//  }
//  otrKit.pollTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:otrKit selector:@selector(messagePoll) userInfo:nil repeats:YES];
  NSLog(@"timer_control_cb");
}

static OtrlMessageAppOps ui_ops = {
  policy_cb,
  create_privkey_cb,
  is_logged_in_cb,
  inject_message_cb,
  update_context_list_cb,
  confirm_fingerprint_received_cb,
  write_fingerprints_cb,
  gone_secure_cb,
  gone_insecure_cb,
  still_secure_cb,
  max_message_size_cb,
  account_display_name_cb,
  account_display_name_free_cb,
  received_symkey_cb,
  otr_error_message_cb,
  otr_error_message_free_cb,
  resent_msg_prefix_cb,
  resent_msg_prefix_free_cb,
  handle_smp_event_cb,
  handle_msg_event_cb,
  create_instag_cb,
  convert_data_cb,
  convert_data_free_cb,
  timer_control_cb
};

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initializer

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TBOTREncryption *)sharedOTREncryption {
  if (sharedOTREncryption==nil) {
    sharedOTREncryption = [[self alloc] init];
  }
  
  return sharedOTREncryption;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self=[super init]) {
    // init otr lib
    OTRL_INIT;
    otr_userstate = otrl_userstate_create();
  }
  
  return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)generatePrivateKeyForAccount:(NSString *)account protocol:(NSString *)protocol {
  NSLog(@"-- asked to generate a private key");
  const char *accountC = [account cStringUsingEncoding:NSUTF8StringEncoding];
  const char *protocolC = [protocol cStringUsingEncoding:NSUTF8StringEncoding];
  OtrlPrivKey *privateKey = otrl_privkey_find(otr_userstate, accountC, protocolC);
  
  if (privateKey) return;
  NSLog(@"-- will generate a private key");
  NSString *privateKeyPath = [self privateKeyPath];
  const char *privateKeyPathC = [privateKeyPath cStringUsingEncoding:NSUTF8StringEncoding];
  
  otrl_privkey_generate(otr_userstate, privateKeyPathC, accountC, protocolC);
}

/*
-(void)generatePrivateKeyForUserState:(OtrlUserState)userState accountName:(NSString *)accountName protocol:(NSString *)protocol startGenerating:(void(^)(void))startGeneratingBlock completion:(void(^)(void))completionBlock
{
  OtrlPrivKey * privateKey = otrl_privkey_find(userState, [accountName UTF8String], [protocol UTF8String]);
  if (!privateKey) {
    if (startGeneratingBlock) {
      startGeneratingBlock();
    }
    [self generatePrivateKeyForUserState:userState accountName:accountName protocol:protocol completion:completionBlock];
  }
  else if(completionBlock) {
    completionBlock();
  }
}
*/

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestOTRSessionWithAccount:(NSString *)account {
	//Note that we pass a name for display, not internal usage
	char *msg = otrl_proto_default_query_msg([account UTF8String], OTRL_POLICY_DEFAULT);

	NSLog(@"-- otr session message : %@", [NSString stringWithUTF8String:msg]);
//	[adium.contentController sendRawMessage:[NSString stringWithUTF8String:(msg ? msg : "?OTRv2?")]
//                                toContact:[inChat listObject]];
	if (msg)
		free(msg);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)privateKeyPath {
  return [[self documentsDirectory] stringByAppendingPathComponent:@"private-key"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (ConnContext *)contextForUsername:(NSString *)username
                        accountName:(NSString *)accountName
                           protocol:(NSString *) protocol {
  ConnContext *context = otrl_context_find(otr_userstate, [username UTF8String],
                                           [accountName UTF8String], [protocol UTF8String],
                                           OTRL_INSTAG_BEST, NO,NULL,NULL, NULL);
  return context;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeMessage:(NSString *)message
            recipient:(NSString *)recipient
          accountName:(NSString *)accountName
             protocol:(NSString *)protocol {
  [[self class] generatePrivateKeyForAccount:accountName protocol:protocol];
  
  ConnContext *context = [self contextForUsername:recipient
                                      accountName:accountName
                                         protocol:protocol];
  gcry_error_t err;
  char *newMessageC = NULL;
  
  err = otrl_message_sending(otr_userstate, &ui_ops, NULL,
                             [accountName UTF8String], [protocol UTF8String], [recipient UTF8String], OTRL_INSTAG_BEST, [message UTF8String], NULL, &newMessageC, OTRL_FRAGMENT_SEND_SKIP, &context,
                             NULL, NULL);
  if (err!=GPG_ERR_NO_ERROR) {
    NSLog(@"!!!!! error while sending the message : %d", err);
  }
  
  if (err==GPG_ERR_NO_ERROR && !newMessageC) {
    NSLog(@"!!!!! There was no error, but an OTR message could not be made.\
          perhaps you need to run some key authentication first...");
  }
  
  NSString *newMessage = @"";
  if (newMessageC) {
    newMessage = [NSString stringWithUTF8String:newMessageC];
  }
  
  otrl_message_free(newMessageC);
  
  NSLog(@"-- org message : %@", message);
  NSLog(@"-- encrypted message : %@", newMessage);
}



//char		*fullOutgoingMessage = NULL;
//
//gcry_error_t err;
//
//if (!username || !originalMessage)
//return;
//
//err = otrl_message_sending(otrg_plugin_userstate, &ui_ops, /* opData */ NULL,
//                           accountname, protocol, username, originalMessage, /* tlvs */ NULL, &fullOutgoingMessage,
//                           /* add_appdata cb */NULL, /* appdata */ NULL);
//
//if (err && fullOutgoingMessage == NULL) {
//  //Be *sure* not to send out plaintext
//  [inContentMessage setEncodedMessage:nil];
//  
//} else if (fullOutgoingMessage) {


/*
- (void) encodeMessage:(NSString*)message recipient:(NSString*)recipient accountName:(NSString*)accountName protocol:(NSString*)protocol startGeneratingKeysBlock:(void (^)(void))generatingKeysBlock success:(void (^)(NSString * message))success
{
  __block gcry_error_t err;
  __block char *newmessage = NULL;
  
  
  __block ConnContext *context = [self contextForUsername:recipient accountName:accountName protocol:protocol];
  
  NSString * (^encodeBlock)(void) = ^() {
    err = otrl_message_sending(userState, &ui_ops, NULL,
                               [accountName UTF8String], [protocol UTF8String], [recipient UTF8String], OTRL_INSTAG_BEST, [message UTF8String], NULL, &newmessage, OTRL_FRAGMENT_SEND_SKIP, &context,
                               NULL, NULL);
    NSString *newMessage = nil;
    //NSLog(@"newmessage char: %s",newmessage);
    if(newmessage)
      newMessage = [NSString stringWithUTF8String:newmessage];
    else
      newMessage = @"";
    
    otrl_message_free(newmessage);
    
    return newMessage;
  };
  
  __block NSString * finalMessage = nil;
  //need to check/create keys
  [self generatePrivateKeyForUserState:userState accountName:accountName protocol:protocol startGenerating:generatingKeysBlock completion:^{
    finalMessage = encodeBlock();
    if (success) {
      success(finalMessage);
    }
  }];
}
*/

@end