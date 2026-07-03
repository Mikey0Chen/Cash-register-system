package com.cashregister;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.cashregister.mapper")
public class CashRegisterApplication {

    public static void main(String[] args) {
        SpringApplication.run(CashRegisterApplication.class, args);
        System.out.println("========================================");
        System.out.println("Cash Register System started.");
        System.out.println("========================================");
    }
}
