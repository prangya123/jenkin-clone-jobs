import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

public class DashboardAutomationFinalReport {
	
	public static void main(String[] args) {
		
		try{
			File reportFolder = new File(args[1]);
			if(!reportFolder.exists())
				reportFolder.mkdir();
			
			Map<String,List<String>> spaceTenantmap = getSpaceTenantMapping(args[0]);
			
			createDashboardHTMLPage(spaceTenantmap, args[0], reportFolder);
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}
	
	public static List<String> getListOfSubDirectoryName(File parent){
		if(parent.isDirectory())
		{
			List<String> listOfDirectories  = new LinkedList<String>();
			
			for(File f : parent.listFiles()){
				if(f.isDirectory()){
					listOfDirectories.add(f.getName());
					System.out.println("Found tenant : "+f.getName());
				}
			}
			return listOfDirectories;
		}
		else{
			System.out.println("Given location is for FILE not for DIRECTORY");
			return null;
		}
	}
	
	
	public static Map<String,List<String>> getSpaceTenantMapping(String inputFolder){
		Map<String,List<String>> spaceTenantmap = new HashMap<String,List<String>>();
		String space;
		List<String> tenantList;
		
		for(String aliasFile : getListOfSubDirectoryName(new File(inputFolder))){
			space = aliasFile.split("-")[1];
			if(spaceTenantmap.containsKey(space)){
				spaceTenantmap.get(space).add(aliasFile);
			}
			else{
				tenantList = new ArrayList<String>();
				tenantList.add(aliasFile);
				spaceTenantmap.put(space, tenantList);
			}
		}
		
//		System.out.println(spaceTenantmap);
		return spaceTenantmap;
	}
	
	public static void createDashboardHTMLPage(Map<String,List<String>> spaceTenantmap,String inputFolderPath, File reportFolder) throws IOException{
		File htmlFile;
		PrintWriter out;
		String space;
		for(Entry<String, List<String>> entry : spaceTenantmap.entrySet()){
			space = entry.getKey();
			System.out.println("Creating HTML dashboard page for space : "+space+"\n at "+reportFolder.getAbsolutePath()+"\\"+space+"_automation.html");
			htmlFile= new File(reportFolder.getAbsolutePath()+"\\"+space+"_automation.html");
			
			//delete then create html file if file already exists
			if(htmlFile.exists())
				htmlFile.delete();
			htmlFile.createNewFile();
			
			
			
			out = new PrintWriter(new FileWriter(htmlFile));
			
			out.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">"
					+ "<link rel=\"stylesheet\" type=\"text/css\" href=\"../css/reportformat.css\">"
					+ "</head>"
					+ "<body> <br>"
					+ "	<h1 align=\"center\">"+space.toUpperCase()+" Automation Test Report Dashboard</h1>	<br>"
					+ "<div>	<table id=\"mytable\" align=\"center\" border=\"2\" >	<tbody>	<tr><th>Tenant </th><th>Automation Report Link</th></tr>");
			
							
			for(String tenantName : entry.getValue()){
				out.println("<tr>"
						+ "<td>"+tenantName+"</td>"
						+ "<td><a href=\""+inputFolderPath+"/"+tenantName+"/cucumber-html-reports/feature-overview.html\"> Automation Test Reports for "+tenantName+"</td>"
						+ "</tr>");
			}	
			
			out.println("</tbody></table>	</div>	<script id=\"wappalyzer\" src=\"chrome-extension://gppongmhjkpfnbhagpmjfkannfbllamg/js/inject.js\"></script></body></html>");
			out.close();
			
		}
	}
}
