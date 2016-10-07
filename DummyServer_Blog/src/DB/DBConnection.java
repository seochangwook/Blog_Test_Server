package DB;

import java.sql.*;

public class DBConnection 
{
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
}
