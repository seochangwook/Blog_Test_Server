package Facebook;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

public class FacebookInfo {
	//안드로이드에서 넘어온 AccessToken값을 저장//
	private String accessToken;
	
	//http://graph.facebook.com/893741967425049/picture?type=large - 프로필 이미지 주소//
	
	public FacebookInfo(String accessToken)
	{
		this.accessToken = accessToken;
	}
	
	public String get_accessToken()
	{
		return this.accessToken;
	}
	
	//그래프api를 이용해서 정보를 가져온다.//
	public String getFBGraph()
	{
		String graph = null;
		
		try {

			String g = "https://graph.facebook.com/me?fields=id,name,email,gender&access_token=" + accessToken;
			
			URL u = new URL(g);
			URLConnection c = u.openConnection();
			BufferedReader in = new BufferedReader(new InputStreamReader(
					c.getInputStream()));
			String inputLine;
			StringBuffer b = new StringBuffer();
			while ((inputLine = in.readLine()) != null)
				b.append(inputLine + "\n");
			in.close();
			graph = b.toString();
			//System.out.println(graph);
		} catch (Exception e) {
			e.printStackTrace();
			
			return "false";
			
			//throw new RuntimeException("ERROR in getting FB graph data. " + e);
		}
		return graph;
	}
}
