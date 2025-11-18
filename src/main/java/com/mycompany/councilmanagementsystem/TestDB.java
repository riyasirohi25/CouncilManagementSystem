/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.councilmanagementsystem;

/**
 *
 * @author Lenovo
 */
import java.sql.Connection;

public class TestDB {
    public static void main(String[] args) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            if (conn != null) {
                System.out.println("Connection Test: SUCCESS");
            } else {
                System.out.println("Connection Test: FAILED");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
