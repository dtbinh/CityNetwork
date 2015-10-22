/**
 * 
 */
package utils.connexion.tor;

import java.io.BufferedReader;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class StreamDisplayer extends Thread {
	
	private BufferedReader reader;
	
	public StreamDisplayer(BufferedReader r){
		reader = r;
	}
	
	@Override
	public void run(){
		try{
			String currentLine=reader.readLine();
			while(true&&currentLine!=null){
				System.out.println(currentLine);currentLine = reader.readLine();
			}
		}catch(Exception e){e.printStackTrace();}
	}
	
}