<%@ page language="java" contentType="text/json; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@page import="org.json.simple.JSONArray"%>
<%@page import="Log.log" %>
<%@page import="java.util.*"%>
<%@page import="Facebook.FacebookInfo"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONObject"%>

<%
//Charcterset//
request.setCharacterEncoding("UTF-8");
%>
<%
//필요한 변수를 할당//
String receive_facebook_accesstoken = "";
//구글 FCM서비스 토큰값//
String receive_fcm_token = "";

//페이스북 계정 정보//
String user_id = "";
String user_name = "";
String user_email = "";
String user_profileimageurl = "";
String user_gender = "";

String endpoint_imageurl = "http://graph.facebook.com/";
String imagesize_url = "/picture?type=normal";

//데이터베이스 저장에 필요한 변수(프로필 정보를 출력 시 필요. 공유 저장소에 정보가 있지만 로그아웃한 상태를 판단하기 위해)//
int login_check = 1; //1이면 기본 로그인이 되어있다는 경우(처음 로그인하거나 다시 로그인으로 들어왔을 경우는 다 로그인 했다고 설정)//

//로그인 성공유무에 대한 변수//
boolean is_success = true;
boolean is_save = false; //처음은 실패라 가정//
log log_file = new log();
%>
<%
receive_facebook_accesstoken = getParameter(request, "accessToken", "");
receive_fcm_token = getParameter(request, "registrationToken", "");
%>
<%
//클라이언트에서 전송된 토큰값을 가지고 페이스북 서버에 인증을 요청 후 프로필 정보를 json으로 받아옴.//
FacebookInfo facebookinfo = new FacebookInfo(receive_facebook_accesstoken);

System.out.println("accessToken: "+facebookinfo.get_accessToken());
System.out.println("fcm token: "+receive_fcm_token);

String json_data = facebookinfo.getFBGraph();

if(json_data.equals("false"))
{
	is_success = false;	
}

System.out.println("json data: "+json_data);
%>
<%
if(is_success == true) //페이스북 서버 인증에 성공했을 경우 수행//
{
	//json파싱을 통해 값을 가져온다.//
	JSONObject json_obj = new JSONObject(json_data);

	//키값으로 가져온다.//
	user_id = json_obj.getString("id");
	user_name = json_obj.getString("name");
	user_email = json_obj.getString("email");
	user_gender = json_obj.getString("gender");
	//프로필 이미지의 주소는 그래프 api가 아닌 profile을 이용//
	user_profileimageurl = endpoint_imageurl + user_id + imagesize_url;
}

System.out.println("user id: "+user_id);
System.out.println("user name: "+user_name);
System.out.println("user email: "+user_email);
System.out.println("user gender: "+user_gender);
System.out.println("user photoimageurl: "+user_profileimageurl);
%>
<%
//id값을 가지고 기존 저장된 사용자인지 판단.(데이터베이스 작업)//
if(is_success == true) //기존 json데이터를 정상적으로 획득 시 작업 시작//
{
	System.out.println("DB function call");
	
	//비교(이미 저장되어 있는지 판단) - 저장되어있으면(UPDATE), 새로운 사용자면(INSERT)수행.//
	//업데이트를 해야될 항목은 액세스토큰과, fcm토큰값, 인증여부//
	//액세스 토큰과 fcm토큰의 값은 로그인 시 마다 최신의 데이터로 유지//
	
	
}
%>
<%
//파싱된 결과를 json으로 전달//
//JSON 생성(넘어갈 데이터는 유저정보이니 JSONArray는 필요없다.)//
JSONObject result_object = new JSONObject();

result_object.put("is_success", ""+is_success); //문자열로 검색 성공과 실패를 판단. 성공 시 내부 result객체에 정보가 있다는 의미//
//검색조건에 따른 각각의 json데이터를 만들어 준다.//
JSONObject user_object = new JSONObject();

user_object.put("user_id", user_id);
user_object.put("user_profileimageurl", user_profileimageurl);
user_object.put("user_name", user_name);
user_object.put("user_email", user_email);
user_object.put("user_gender", user_gender);

result_object.put("result", user_object);

out.clear(); //보내기전 기존 출력내용을 초기화//
out.println(result_object); //데이터 출력 및 전송//
out.flush(); //출력버퍼에 있는 데이터를 모두 초기화//
%>
<%
//로그정보 기록//
String client_ipaddr = request.getRemoteAddr();
String log_data = "["+client_ipaddr+"] call [login]";

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
//함수선언(method: POST)//
public String getParameter(HttpServletRequest request, String parameter_name, String default_value)
{
	String return_str;
	
	return_str = request.getParameter(parameter_name);
	
	if(return_str == null || return_str.equals(""))
	{
		return_str = default_value;
	}
	
	else if(return_str != null)
	{
		
	}
	
	return return_str;
}
%>
