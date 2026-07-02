package com.cocktail;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.cocktail.mapper")
public class CocktailBarApplication {

    public static void main(String[] args) {
        SpringApplication.run(CocktailBarApplication.class, args);
        System.out.println("========================================");
        System.out.println("🍸 鸡尾酒收银系统启动成功！");
        System.out.println("========================================");
    }
}
