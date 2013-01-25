package example;

import java.io.Serializable;

public class Monkey implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;   
	
	public int age;
	public String name;
	
	public Monkey(){}

	public int getAge() {
		return age;
	}

	public void setAge(int age) {
		this.age = age;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
