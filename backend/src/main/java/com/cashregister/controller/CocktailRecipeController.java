package com.cashregister.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cashregister.common.Result;
import com.cashregister.dto.RecipeDTO;
import com.cashregister.entity.CocktailRecipe;
import com.cashregister.service.CocktailRecipeService;
import com.cashregister.vo.CocktailRecipeVO;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 鸡尾酒配方控制器
 */
@RestController
@RequestMapping("/recipe")
@CrossOrigin
@RequiredArgsConstructor
public class CocktailRecipeController {

    private final CocktailRecipeService recipeService;

    /**
     * 分页查询配方列表
     */
    @GetMapping("/page")
    public Result<Page<CocktailRecipe>> getRecipePage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword
    ) {
        Page<CocktailRecipe> page = recipeService.getRecipePage(current, size, category, keyword);
        return Result.success(page);
    }

    /**
     * 获取配方详情
     */
    @GetMapping("/{id}")
    public Result<CocktailRecipeVO> getRecipeDetail(@PathVariable Long id) {
        CocktailRecipeVO vo = recipeService.getRecipeDetail(id);
        return Result.success(vo);
    }

    /**
     * 创建配方
     */
    @PostMapping
    public Result<Long> createRecipe(@RequestBody @Validated RecipeDTO dto) {
        Long id = recipeService.createRecipe(dto);
        return Result.success("创建成功", id);
    }

    /**
     * 更新配方
     */
    @PutMapping
    public Result<Void> updateRecipe(@RequestBody @Validated RecipeDTO dto) {
        if (dto.getId() == null) {
            return Result.error("配方ID不能为空");
        }
        recipeService.updateRecipe(dto);
        return Result.success("更新成功", null);
    }

    /**
     * 删除配方
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteRecipe(@PathVariable Long id) {
        recipeService.deleteRecipe(id);
        return Result.success("删除成功", null);
    }

    /**
     * 检查配方库存
     */
    @GetMapping("/check-stock/{id}")
    public Result<Boolean> checkStock(@PathVariable Long id, @RequestParam Integer quantity) {
        boolean isAvailable = recipeService.checkRecipeStock(id, quantity);
        return Result.success(isAvailable);
    }
}
