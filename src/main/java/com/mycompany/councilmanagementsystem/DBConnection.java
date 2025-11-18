/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.councilmanagementsystem;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 *
 * @author Lenovo
 */
class DBConnection {
      public static Connection getDBConnection(){
       Connection con=null;
       try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/council_db", "root", "1234");
            return con;
        }catch(Exception ex){
            System.out.println("-DB connection error----"+ex.getMessage());
        }
       
       return con;
    }
}
