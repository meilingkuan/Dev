public class Hapara_UtilityFile {
	public static void uploadFile(Blob file_body, String file_name, String reqEndPoint){
      // Repost of code  with fix for file corruption issue
      // Orignal code postings and explanations
      // http://enreeco.blogspot.in/2013/01/salesforce-apex-post-mutipartform-data.html
      // http://salesforce.stackexchange.com/questions/24108/post-multipart-without-base64-encoding-the-body
      // Additional changes commented GW: that fix issue with occasional corruption of files
      String boundary = '----------------------------741e90d31eff';
      String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
      // GW: Do not prepend footer with \r\n, you'll see why in a moment
      // String footer = '\r\n--'+boundary+'--'; 
      String footer = '--'+boundary+'--';             
      String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
      while(headerEncoded.endsWith('='))
      {
       header+=' ';
       headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
      }
      String bodyEncoded = EncodingUtil.base64Encode(file_body);
      // GW: Do not encode footer yet
      // String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));

      Blob bodyBlob = null;
      String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());

      // GW: Replacing this entire section
      /*
      if(last4Bytes.endsWith('='))
      {
           Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
           HttpRequest tmp = new HttpRequest();
           tmp.setBodyAsBlob(decoded4Bytes);
           String last4BytesFooter = tmp.getBody()+footer;   
           bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded.substring(0,bodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
      }
      else
      {
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
      }
      */
	     // GW: replacement section to get rid of padding without corrupting data
	     if(last4Bytes.endsWith('==')) {
	        // The '==' sequence indicates that the last group contained only one 8 bit byte
	        // 8 digit binary representation of CR is 00001101
	        // 8 digit binary representation of LF is 00001010
	        // Stitch them together and then from the right split them into 6 bit chunks
	        // 0000110100001010 becomes 0000 110100 001010
	        // Note the first 4 bits 0000 are identical to the padding used to encode the
	        // second original 6 bit chunk, this is handy it means we can hard code the response in
	        // The decimal values of 110100 001010 are 52 10
	        // The base64 mapping values of 52 10 are 0 K
	        // See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
	        // Therefore, we replace == with 0K
	        // Note: if using \n\n instead of \r\n replace == with 'oK'
	        last4Bytes = last4Bytes.substring(0,2) + '0K';
	        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
	        // We have appended the \r\n to the Blob, so leave footer as it is.
	        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
	        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
	      } else if(last4Bytes.endsWith('=')) {
	        // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
	        // We replace final 8 bit byte with a CR e.g. \r
	        // 8 digit binary representation of CR is 00001101
	        // Ignore the first 2 bits of 00 001101 they have already been used up as padding
	        // for the existing data.
	        // The Decimal value of 001101 is 13
	        // The base64 value of 13 is N
	        // Therefore, we replace = with N
	        // Note: if using \n instead of \r replace = with 'K'
	        last4Bytes = last4Bytes.substring(0,3) + 'N';
	        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
	        // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
	        footer = '\n' + footer;
	        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
	        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
	      } else {
	        // Prepend the CR LF to the footer
	        footer = '\r\n' + footer;
	        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
	        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
	      }
	
	      HttpRequest req = new HttpRequest();
	      req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
	      req.setMethod('POST');
	      req.setEndpoint(reqEndPoint);
	      req.setBodyAsBlob(bodyBlob);
	      req.setTimeout(120000);
	
	      Http http = new Http();
	      HTTPResponse res = http.send(req);
	}   
}