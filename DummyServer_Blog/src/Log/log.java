package Log;

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Calendar;

public class log 
{
	//log file(absolute path)//
	private static final String LOGFILE = "/Users/apple/Desktop/Programmingfile/web_developer/Blog_logfile/log.txt";
	private boolean is_save = false;
	private static final int CONTENT = 0;
	private static final int DIVIDECONTENT = 1;
	
	/** Log data setting **/
	public static String getCurrentDate()
	{
		String currentDate = "";
		
		Calendar calendar = Calendar.getInstance(); //current time/date info setting//
		
		//get date/time//
		String year = new Integer(calendar.get(Calendar.YEAR)).toString();
		String month = new Integer(calendar.get(Calendar.MONTH)+1).toString();
		String day = new Integer(calendar.get(Calendar.DATE)).toString();
		String hour = new Integer(calendar.get(Calendar.HOUR)).toString();
		String minute = new Integer(calendar.get(Calendar.MINUTE)).toString();
		
		if(month.trim().length() ==1)
		{
			month = "0"+month;
		}
		
		if(day.trim().length() ==1)
		{
			day = "0"+day;
		}
		
		currentDate = month+"/"+day+"/"+year+" - "+hour+":"+minute;
		
		return currentDate;
	}
	
	/** log info file save **/
	public static boolean SaveLogInfo(String contentToWrite, int flag)
	{
		boolean is_save = true;
		
		try
		{
			if(flag == 0) //content save//
			{
				contentToWrite = log.getCurrentDate() + " ("+contentToWrite+")"+"\r\n";
				
				OutputStream os = new FileOutputStream(log.LOGFILE, true); //true로 append옵션 활성화//
				DataOutputStream out = new DataOutputStream(os);
				OutputStreamWriter osw = new OutputStreamWriter(out);
				
				osw.write(contentToWrite);
				
				osw.close();
				out.close();
				os.close();
			}
			
			else if(flag == 1) //divide save//
			{
				contentToWrite = "Success ..."+"\r\n"+contentToWrite+"\r\n";
				
				OutputStream os = new FileOutputStream(log.LOGFILE, true); //true로 append옵션 활성화//
				DataOutputStream out = new DataOutputStream(os);
				OutputStreamWriter osw = new OutputStreamWriter(out);
				
				osw.write(contentToWrite);
				
				osw.close();
				out.close();
				os.close();
			}
		}
		
		catch(Exception e)
		{
			is_save = false;
		}
		
		return is_save;
	}
}
