package FCM;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import com.google.android.gcm.server.Message;
import com.google.android.gcm.server.Message.Builder;
import com.google.android.gcm.server.MulticastResult;
import com.google.android.gcm.server.Result;
import com.google.android.gcm.server.Sender;

import DB.DBConnection;

public class FCM_Sender {
	private static final String SERVER_APIKEY = "AIzaSyA-TPJ-6ueqhzcdFlCxz0A5SgBVKTuN1MI";
	private static final String DB_COLUMN = "fcm_token"; //고정컬럼//
	
	private static final String MESSAGE_ID = "demo";
	private static final boolean SHOW_ON_IDLE = true;
	private static final int LIVE_TIME = 3;
	static final String TITLE_EXTRA_KEY = "TITLE";
    static final String MSG_EXTRA_KEY = "MSG";
    
    private Message message;
    List<String>receiver_list;
    
    String user_name;
    
    public FCM_Sender(String user_name)
    {
    	this.user_name = user_name;
    	
    	receiver_list = new ArrayList<String>();
    }
	
	public void sendMessage() throws IOException
	{
		//데이터베이스 연결객체를 가져온다.//
		Connection con = DBConnection.makeConnection();

		//PrepareStatement 설정//
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		//기본적으로 전체 등록된 유저로 가정(필요에 의해서 조인을 이용한 알람 그룹 지정)//
		String query = "select fcm_token from user";
		
		try {
			pstmt = con.prepareStatement(query);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		try {
			rs = pstmt.executeQuery();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//서버의 api키//
		Sender sender = new Sender(SERVER_APIKEY);
		
		try {
			//나를 포함하여 현재 앱에 등록된 사람들에게 알린다.//
			while(rs.next())
			{
				//후에 이부분에 값을 데이터베이스로 설정한다.(현재는 나 자신으로 설정)//
				String regID = rs.getString(DB_COLUMN);
			
				//전송받을 토큰들 등록(ex)나를 기준으로 나하고 친구가 되있는 사람들목록) //
				receiver_list.add(regID);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//메세지 생성//
		//우선적으로 날짜를 얻어온다.//
		String login_date = getCurrentDate();
		
		Builder builder = new Message.Builder();
		builder.collapseKey(MESSAGE_ID);
		builder.delayWhileIdle(SHOW_ON_IDLE);
		builder.timeToLive(LIVE_TIME);
		builder.addData(TITLE_EXTRA_KEY, "Human Management");
		builder.addData(MSG_EXTRA_KEY, user_name+"회원님 로그인 하셨습니다.("+login_date+")");
		message = builder.build();
				
		MulticastResult multiResult = sender.send(message, receiver_list, 5);	
		
		if(multiResult != null)
		{
			List<Result> resultList = multiResult.getResults();
			
			for(Result result : resultList)
			{
				System.out.println("print" +result.getMessageId());
			}
		}
	}
	
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
}
