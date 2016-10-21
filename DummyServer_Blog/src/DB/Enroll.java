package DB;

import java.sql.*;

public class Enroll {
	public static Connection makeConnection()
	{
		String url = "jdbc:mysql://localhost/blogtest"; //디비 경로//
		String id = "root"; //디비 접속id//
		String password = "3315"; //디비 접속 password//
		
		Connection con = null;
		
		try
		{
			Class.forName("com.mysql.jdbc.Driver"); //JDBC를 적재한다.//
			System.out.println("Driver loading Success...");
			
			con = DriverManager.getConnection(url, id, password); //연결//
			
			System.out.println("DataBase Connection Success...");
		}
		
		catch(ClassNotFoundException exception)
		{
			System.out.println("Driver not search...");
		}
		
		catch(SQLException exception)
		{
			System.out.println("DataBase Connection Fail...");
			
			exception.printStackTrace();
		}
		
		return con;
	}
	
	//사용자 정보를 등록//
	public boolean enroll_userinfo(
			String user_id,
			String user_email,
			String user_name,
			String user_gender,
			String user_profileimageurl,
			String accessToken,
			String fcm_token,
			String auth_login)
	{
		boolean is_success = true; //성공이라 가정//
		
		//연결객체 생성//
		Connection con = Enroll.makeConnection();
		
		System.out.println("Database load success... / enroll user info");
		
		//PrepareStatement 설정//
		PreparedStatement pstmt = null;
		
		try
		{	
			String query = "INSERT INTO user(user_id, user_name, user_email, user_gender,"
					+ "user_imageurl, access_token, fcm_token, auth_login) VALUES(?,?,?,?,?,?,?,?)";
			
			pstmt = con.prepareStatement(query);
			
			//값 셋팅//
			pstmt.setString(1, user_id);
			pstmt.setString(2, user_name);
			pstmt.setString(3, user_email);
			pstmt.setString(4, user_gender);
			pstmt.setString(5, user_profileimageurl);
			pstmt.setString(6, accessToken);
			pstmt.setString(7, fcm_token);
			pstmt.setString(8, auth_login);
			
			//쿼리 적용//
			int result_code = pstmt.executeUpdate();
			
			if(result_code == 0)
			{
				is_success = false;
			}
			
			return is_success;
		}
		
		catch(SQLException e)
		{
			e.printStackTrace();
		}
		
		finally //자원해제//
		{
			try {
				pstmt.close();
				con.close();
			}
			
			catch(SQLException e)
			{
				e.printStackTrace();
			}
		}
		
		return is_success;
	}
	
	public boolean update_userinfo(String user_id, String acccesstoken, String fcm_token, String auth_login)
	{
		boolean is_update = true; //성공이라 가정//
		
		//연결객체 생성//
		Connection con = Enroll.makeConnection();
				
		System.out.println("Database load success... / update user info");
				
		//PrepareStatement 설정//
		PreparedStatement pstmt = null;
		
		try
		{	
			String query = "UPDATE user SET access_token = ?, fcm_token = ?, auth_login = ? WHERE user_id = ?";
			
			pstmt = con.prepareStatement(query);
			
			pstmt.setString(1, acccesstoken);
			pstmt.setString(2, fcm_token);
			pstmt.setString(3, auth_login);
			pstmt.setString(4, user_id);
			
			//쿼리 적용//
			int result_code = pstmt.executeUpdate();
			
			if(result_code == 0)
			{
				is_update = false;
			}
			
			return is_update;
		}
		
		catch(SQLException e)
		{
			e.printStackTrace();
		}
		
		finally //자원해제//
		{
			try {
				pstmt.close();
				con.close();
			}
			
			catch(SQLException e)
			{
				e.printStackTrace();
			}
		}
		
		return is_update;
	}
	
	//기존 등록된 유저인지 검사//
	public boolean enroll_ischeck(String user_id)
	{
		boolean is_check = true; //처음은 아이디가 없다고 가정(가입가능)//
		//만약 동일 id가 이미 존재 시 가입 불가로 false반환//
		
		Connection con = Enroll.makeConnection(); //연결객체 반환//
		
		System.out.println("Database load success... / enroll check("+user_id+")");
		
		//PrepareStatement 설정//
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		//id검사작업 진행//
		try
		{
			String query = "select user_id from user where user_id = ?";
			pstmt = con.prepareStatement(query);
			
			pstmt.setString(1, user_id); //?가 있는 곳에 조건을 넣어준다.//
			rs = pstmt.executeQuery();
			
			while(rs.next())
			{	
				if(user_id.equals(rs.getString("user_id")))
				{
					//같은 값이 나오면 이미 존재하는 것. 더이상 비교는 필요없다.//
					is_check = false;
					
					break;
				}
			}
			
			return is_check;
		}
		
		catch (SQLException e) 
		{
		    e.printStackTrace();
		}

		finally
		{
			//자원을 해제한다.//
			try {
				pstmt.close();
				rs.close();
				con.close();
			}
			
			catch(SQLException e)
			{
				e.printStackTrace();
			}
		}
		
		return is_check;
	}
}
