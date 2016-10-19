<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@page import="java.sql.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="Log.log" %>
<%@page import="DB.*"%>
<%@page import="com.oreilly.servlet.multipart.*"%> //파일전송을 위한 라이브러리 적용//
<%@page import="com.oreilly.servlet.*"%> //파일전송을 위한 라이브러리 적용//
<%@page import="java.util.*"%>

<%
//Charcterset//
request.setCharacterEncoding("UTF-8");
%>
<%
//variable//
String name;
String imagefilename = "";
String etc;
String department_name;
String introduction;
String age;
String tel;
String job;
String address;
String emailaddress;

boolean is_enroll = true; //등록성공이라 가정//
//우선 저장할려는 사람이 이미 등록되어 있는지 검사//
boolean is_enroll_already; //기본적으로 가입이 안되었다는 가정//

boolean is_save = false; //처음은 실패라 가정//
log log_file = new log();
%>
<%
//image save path(다시 클라이언트로 전송 시 해당 경로값을 적용)//
String uploadPath = "/Users/apple/git/BlogtestServer/DummyServer_Blog/WebContent/images";
//image max size(exception)//
int size = 10*1024*1024;
%>
<%
//전달된 값을 받아온다.//
//MultipartRequest 적용(파일이나 대용량 데이터 보낼때 데이터 전송방식)//
//해당 서버로 데이터 전송 시 POST타입 : form-data//
//어렵게 MultipartRequest를 구현없이 cos.jar에 MultipartRequest를 사용//
MultipartRequest multirequest = new MultipartRequest(request, uploadPath, size, "utf-8", new DefaultFileRenamePolicy());

name = getMultiParameter(multirequest, "human_name", "user");
etc = getMultiParameter(multirequest, "human_etcinfo", "");
department_name = getMultiParameter(multirequest, "human_departmentname", "");
introduction = getMultiParameter(multirequest, "human_introduction", "");
age = getMultiParameter(multirequest, "human_age", "");
tel = getMultiParameter(multirequest, "human_tel", "");
job = getMultiParameter(multirequest, "human_job", "");
address = getMultiParameter(multirequest, "human_address", "");
emailaddress = getMultiParameter(multirequest, "human_emailaddress", "");

//업로드한 파일들을 Enumeration타입으로 반환//
//Enumeration형은 데이터를 뽑아올때 유용한 인터페이스//
try
{
	Enumeration files = multirequest.getFileNames();
	
	int image_count = 0;
	
	//현재는 가장 마지막거를 기준으로 하지만 여러개의 이미지를 받을 필요 시 배열에 저장 후 관련 디비에 저장// 
	while(files.hasMoreElements())
	{
		imagefilename = multirequest.getFilesystemName((String)files.nextElement());
		System.out.println("image file name: "+imagefilename);
		
		image_count++;
	}
	
	if(image_count == 0) //이미지가 한개도 오지 않았을 경우//
	{
		imagefilename = "default_humanimage.png";
	}
}

catch(Exception e)
{
	//디폴트 이미지 처리(당장에 보여질 사진이 없기에 처리)//
	imagefilename = "default_humanimage.png";
}
//이미지에 대한 저장은 파일이름이 저장되고, 출력 시 경로를 붙여준다.(길이문제 고려)//
%>
<%
//정보저장 작업(데이터베이스)//
//데이터베이스 연결객체를 가져온다.//
Connection con = DBConnection.makeConnection();

//PrepareStatement 설정//
PreparedStatement pstmt = null;

try
{
	//저장을 하기 전 중복가입여부를 판단(동명이인을 판단하기 위한 개발부서까지 조건에 추가)//
	is_enroll_already = CheckEnrollDuplicate(name, department_name);
	
	if(is_enroll_already == false)
	{
		System.out.println("insert upload file: "+imagefilename);
		
		String query = "INSERT INTO human(human_imageurl, human_age, human_tel, human_job, human_department, human_address, human_emailaddress, human_introduction, human_etcinfo, human_name) VALUES(?,?,?,?,?,?,?,?,?,?)";
		pstmt = con.prepareStatement(query);
	
		//값 셋팅//
		pstmt.setString(1, imagefilename);
		pstmt.setString(2, age);
		pstmt.setString(3, tel);
		pstmt.setString(4, job);
		pstmt.setString(5, department_name);
		pstmt.setString(6, address);
		pstmt.setString(7, emailaddress);
		pstmt.setString(8, introduction);
		pstmt.setString(9, etc);
		pstmt.setString(10, name);
	
		int result_code = pstmt.executeUpdate();
	
		if(result_code == 0)
		{
			is_enroll = false;
		}
	}
	
	else if(is_enroll_already == true)
	{
		is_enroll = false; //저장실패의 경우로 판단//
	}
}

catch(Exception e)
{
	e.getMessage();
}
%>
<%
//응답 json메시지 설정//
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();

//검색조건에 따른 각각의 json데이터를 만들어 준다.//
JSONObject user_object = new JSONObject();

user_object.put("is_save", is_enroll);

result_object.put("result", user_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call ["+name+"] member add";

is_save = log_file.SaveLogInfo(log_data, 0);
is_save = log_file.SaveLogInfo("---------------------------------", 1);

if(is_save == false)
{
	System.out.println("Save Log ERROR");
}

else if(is_save == true)
{
	System.out.println("Save Log SUCCESS");
}
%>
<%!
public String getMultiParameter(MultipartRequest multirequest, String parameter_name, String default_value)
{
	String parameter_value = "";
	
	parameter_value = multirequest.getParameter(parameter_name);
	
	if(parameter_value == null || parameter_value.equals(""))
	{
		parameter_value = default_value;
	}
	
	return parameter_value;
}
%>
<%!
public boolean CheckEnrollDuplicate(String name, String department_name)
{
	boolean is_check = false; //가입이 안되었다는 가정//

	//데이터베이스에서 검색작업 실시//
	//데이터베이스 연결객체를 가져온다.//
	Connection con = DBConnection.makeConnection();

	//PrepareStatement 설정//
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	ResultSetMetaData rsmt = null;
	
	try
	{
		String query = "select human_name, human_department from human";
		pstmt = con.prepareStatement(query);
		
		rs = pstmt.executeQuery(); //쿼리문을 수행//
		
		while(rs.next())
		{
			//존재하는지 비교//
			String search_name = rs.getString("human_name");
			String search_departmentname = rs.getString("human_department");
			
			if(search_name.equals(name) && search_departmentname.equals(department_name))
			{
				//해당 정보가 이미 존재//
				is_check = true;
				
				break; //더 이상 검색필요없으니 종료.//
			}
		}
		
		return is_check;
	}
	
	catch(SQLException e)
	{
		e.getMessage();
	}
	
	finally
	{
		//자원을 해제한다.//
		try
		{
			pstmt.close();
			rs.close();
			con.close();
		}
		
		catch(SQLException e)
		{
			e.getMessage();
		}
	}
	
	return is_check;
}
%>