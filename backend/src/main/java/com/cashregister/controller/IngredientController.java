package com.cashregister.controller;

import com.cashregister.common.Result;
import com.cashregister.entity.Ingredient;
import com.cashregister.mapper.IngredientMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 原料控制器
 */
@RestController
@RequestMapping("/ingredient")
@CrossOrigin
@RequiredArgsConstructor
public class IngredientController {

    private final IngredientMapper ingredientMapper;

    /**
     * 获取所有原料列表
     */
    @GetMapping("/list")
    public Result<List<Ingredient>> getIngredientList() {
        List<Ingredient> list = ingredientMapper.selectList(null);
        return Result.success(list);
    }

    /**
     * 根据ID获取原料详情
     */
    @GetMapping("/{id}")
    public Result<Ingredient> getIngredientById(@PathVariable Long id) {
        Ingredient ingredient = ingredientMapper.selectById(id);
        if (ingredient == null) {
            return Result.error("原料不存在");
        }
        return Result.success(ingredient);
    }

    /**
     * 创建原料
     */
    @PostMapping
    public Result<String> createIngredient(@RequestBody Ingredient ingredient) {
        ingredientMapper.insert(ingredient);
        return Result.success("创建成功");
    }

    /**
     * 更新原料
     */
    @PutMapping
    public Result<String> updateIngredient(@RequestBody Ingredient ingredient) {
        ingredientMapper.updateById(ingredient);
        return Result.success("更新成功");
    }
}
