#!/bin/bash
working=$(pwd)
echo -e "<?xml version=\"1.0\" encoding=\"iso-8859-2\" ?>
<!DOCTYPE scenario SYSTEM \"sipp.dtd\">

<scenario name=\"UAC REGISTER + INVITE + call\">

<!--  Use with CSV file struct like: 32;192.168.1.211;[authentication username=32 password=32];21;
            (user part of uri, server address, auth tag, call target)
-->

  <send retrans=\"1000\">
    <![CDATA[

      REGISTER sip:[remote_ip] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port];branch=[branch]
      From: <sip:[field0]@[field1]>;tag=[call_number]
      To: <sip:[field0]@[field1]>
      Call-ID: [call_id]
      CSeq: [cseq] REGISTER
      Contact: sip:[field0]@[local_ip]:[local_port]
      Max-Forwards: 10
      Expires: 120
      User-Agent: SIPp
      Content-Length: 0

    ]]>
  </send>

  <!-- asterisk -->
  <recv response=\"100\" optional=\"true\">
  </recv>
  <recv response=\"401\" auth=\"true\">
  </recv>
  
  <send retrans=\"1000\">
    <![CDATA[

      REGISTER sip:[remote_ip] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port];branch=[branch]
      From: <sip:[field0]@[field1]>;tag=[call_number]
      To: <sip:[field0]@[field1]>
      Call-ID: [call_id]
      CSeq: [cseq] REGISTER
      Contact: sip:[field0]@[local_ip]:[local_port]
      Max-Forwards: 10
      [field2]
      Expires: 120
      User-Agent: SIPp
      Content-Length: 0

    ]]>
  </send>


  <!-- asterisk -->
  <recv response=\"200\">
  </recv>

  <send retrans=\"500\">
    <![CDATA[

      INVITE sip:[field3]@[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port];branch=[branch]
      From: sipp <sip:[field0]@[field1]>;tag=[call_number]
      To: <sip:[field3]@[field1]:[remote_port]>
      Call-ID: [call_id]
      CSeq: [cseq] INVITE
      Contact: sip:[field0]@[local_ip]:[local_port]
      Max-Forwards: 70
      Content-Type: application/sdp
      Content-Length: [len]

      v=0
      o=user1 53655765 2353687637 IN IP[local_ip_type] [local_ip]
      s=-
      c=IN IP[media_ip_type] [media_ip]
      t=0 0
      m=audio [auto_media_port] RTP/AVP 0 8 96
      a=rtpmap:0 PCMU/8000
      a=rtpmap:8 PCMA/8000
      a=rtpmap:96 telephone-event/8000
      a=fmtp:96 0-11
      
    ]]>
  </send>

  <recv response=\"100\" optional=\"true\">
  </recv>
  <recv response=\"401\" auth=\"true\">
  </recv>


  <send retrans=\"500\">
    <![CDATA[

      INVITE sip:[field3]@[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port];branch=[branch]
      From: sipp <sip:[field0]@[field1]>;tag=[call_number]
      To: <sip:[field3]@[field1]:[remote_port]>
      Call-ID: [call_id]
      CSeq: [cseq] INVITE
      Contact: sip:[field0]@[local_ip]:[local_port]
      Max-Forwards: 70
      [field2]
      Content-Type: application/sdp
      Content-Length: [len]

      v=0
      o=user1 53655765 2353687637 IN IP[local_ip_type] [local_ip]
      s=-
      c=IN IP[media_ip_type] [media_ip]
      t=0 0
      m=audio [auto_media_port] RTP/AVP 0 8 96
      a=rtpmap:0 PCMU/8000
      a=rtpmap:8 PCMA/8000
      a=rtpmap:96 telephone-event/8000
      a=fmtp:96 0-11
      
    ]]>
  </send>

  <recv response=\"100\" optional=\"true\">
  </recv>

  <recv response=\"180\" optional=\"true\">
  </recv>

  <recv response=\"183\" optional=\"true\">
  </recv>

  <recv response=\"603\" optional=\"true\">
  </recv>

  <recv response=\"200\" rtd=\"true\" crlf=\"true\">
  </recv>

  <send>
    <![CDATA[

      ACK sip:[field3]@[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port];branch=[branch]
      From: <sip:[field0]@[field1]>;tag=[call_number]
      [last_To:]
      Call-ID: [call_id]
      CSeq: [cseq] ACK
      Contact: sip:[field0]@[local_ip]:[local_port]
      Max-Forwards: 10
      Content-Length: 0

    ]]>
  </send>

  <!-- Play a pre-recorded PCAP file (RTP stream)                       
         <nop>
    <action>
      <exec play_pcap_audio=\"pcap/g711_only_30m.pcap\"/>
    </action>
  </nop>
  <pause milliseconds=\"700000\"/>
  -->

  <nop>
    <action>
      <exec play_pcap_audio=\"pcap/g711_only_30m.pcap\"/>
    </action>
  </nop>
  <pause milliseconds=\"8000\"/>
  <pause milliseconds=\"20000\"/>

  <!-- START THE REMOTE PHONE: $1# -->
  <nop>
    <action>
      <exec play_pcap_audio=\"pcap/g711_only_30m.pcap\"/>
    </action>
  </nop>
  <pause milliseconds=\"20000\"/>
  <nop>
    <action>
      <exec play_pcap_audio=\"pcap/$1.pcap\"/>
    </action>
  </nop>
  <pause milliseconds=\"20000\"/>" > voip_1100.xml

for filename in $working/pcaps/*.pcap; do
  echo -e "  <nop>
   <action>
     <exec rtp_stream=\"$filename\" />
   </action>
  </nop>
  <pause milliseconds=\"60000\"/>" >> voip_1100.xml
done

echo -e "  <send retrans=\"500\">
    <![CDATA[

      BYE sip:[field3]@[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port];branch=[branch]
      From: <sip:[field0]@[field1]>;tag=[call_number]      
      [last_To:]
      Call-ID: [call_id]
      CSeq: [cseq] BYE
      Contact: sip:sipp@[local_ip]:[local_port]
      Max-Forwards: 10
      Content-Length: 0

    ]]>
  </send>

  <!-- The 'crlf' option inserts a blank line in the statistics report. -->
  <recv response=\"200\" crlf=\"true\">
  </recv>

  <!-- definition of the response time repartition table (unit is ms)   -->
  <ResponseTimeRepartition value=\"10, 20, 30, 40, 50, 100, 150, 200\"/>

  <!-- definition of the call length repartition table (unit is ms)     -->
  <CallLengthRepartition value=\"10, 50, 100, 500, 1000, 5000, 10000\"/>

  <pause milliseconds=\"20000\"/>
</scenario>" >> voip_1100.xml
