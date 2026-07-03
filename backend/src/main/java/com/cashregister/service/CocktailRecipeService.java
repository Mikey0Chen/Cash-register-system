package com.cashregister.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cashregister.dto.RecipeDTO;
import com.cashregister.dto.RecipeIngredientDTO;
import com.cashregister.entity.CocktailRecipe;
import com.cashregister.entity.Ingredient;
import com.cashregister.entity.RecipeIngredient;
import com.cashregister.exception.BusinessException;
import com.cashregister.mapper.CocktailRecipeMapper;
import com.cashregister.mapper.IngredientMapper;
import com.cashregister.mapper.RecipeIngredientMapper;
import com.cashregister.vo.CocktailRecipeVO;
import com.cashregister.vo.RecipeIngredientVO;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 鸡尾酒配方服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CocktailRecipeService {

    private final CocktailRecipeMapper recipeMapper;
    private final RecipeIngredientMapper recipeIngredientMapper;
    private final IngredientMapper ingredientMapper;
    private final ObjectMapper objectMapper;

    /**
     * 分页查询配方列表
     */
    public Page<CocktailRecipe> getRecipePage(Integer current, Integer size, String category, String keyword) {
        Page<CocktailRecipe> page = new Page<>(current, size);
        LambdaQueryWrapper<CocktailRecipe> wrapper = new LambdaQueryWrapper<>();

        if (category != null && !category.isEmpty()) {
            wrapper.eq(CocktailRecipe::getCategory, category);
        }

        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(CocktailRecipe::getName, keyword)
                    .or().like(CocktailRecipe::getNameEn, keyword));
        }

        wrapper.eq(CocktailRecipe::getStatus, 1)
                .orderByDesc(CocktailRecipe::getSortOrder)
                .orderByDesc(CocktailRecipe::getSalesCount);

        return recipeMapper.selectPage(page, wrapper);
    }

    /**
     * 获取配方详情（含原料）
     */
    public CocktailRecipeVO getRecipeDetail(Long id) {
        CocktailRecipe recipe = recipeMapper.selectById(id);
        if (recipe == null) {
            throw new BusinessException("配方不存在");
        }

        CocktailRecipeVO vo = new CocktailRecipeVO();
        BeanUtils.copyProperties(recipe, vo);

        // 解析口味标签
        try {
            if (recipe.getTasteTags() != null) {
                vo.setTasteTags(objectMapper.readValue(recipe.getTasteTags(), List.class));
            }
        } catch (JsonProcessingException e) {
            log.error("解析口味标签失败", e);
        }

        // 查询原料列表
        List<RecipeIngredientVO> ingredients = getRecipeIngredients(id);
        vo.setIngredients(ingredients);

        return vo;
    }

    /**
     * 查询配方原料列表
     */
    private List<RecipeIngredientVO> getRecipeIngredients(Long recipeId) {
        LambdaQueryWrapper<RecipeIngredient> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(RecipeIngredient::getRecipeId, recipeId)
                .orderByAsc(RecipeIngredient::getSortOrder);

        List<RecipeIngredient> recipeIngredients = recipeIngredientMapper.selectList(wrapper);
        List<RecipeIngredientVO> voList = new ArrayList<>();

        for (RecipeIngredient ri : recipeIngredients) {
            Ingredient ingredient = ingredientMapper.selectById(ri.getIngredientId());
            if (ingredient != null) {
                RecipeIngredientVO vo = new RecipeIngredientVO();
                vo.setIngredientId(ingredient.getId());
                vo.setIngredientName(ingredient.getName());
                vo.setIngredientType(ingredient.getType());
                vo.setQuantity(ri.getQuantity());
                vo.setUnit(ri.getUnit());
                vo.setIsOptional(ri.getIsOptional());
                vo.setStock(ingredient.getStock());
                vo.setSortOrder(ri.getSortOrder());
                voList.add(vo);
            }
        }

        return voList;
    }

    /**
     * 创建配方
     */
    @Transactional(rollbackFor = Exception.class)
    public Long createRecipe(RecipeDTO dto) {
        // 1. 创建配方主表
        CocktailRecipe recipe = new CocktailRecipe();
        BeanUtils.copyProperties(dto, recipe);

        // 将口味标签转为 JSON
        try {
            if (dto.getTasteTags() != null) {
                recipe.setTasteTags(objectMapper.writeValueAsString(dto.getTasteTags()));
            }
        } catch (JsonProcessingException e) {
            throw new BusinessException("口味标签格式错误");
        }

        recipe.setStatus(1);
        recipe.setSalesCount(0);
        recipeMapper.insert(recipe);

        // 2. 创建原料关联
        if (dto.getIngredients() != null && !dto.getIngredients().isEmpty()) {
            saveRecipeIngredients(recipe.getId(), dto.getIngredients());
        }

        // 3. 计算成本价
        updateRecipeCost(recipe.getId());

        return recipe.getId();
    }

    /**
     * 更新配方
     */
    @Transactional(rollbackFor = Exception.class)
    public void updateRecipe(RecipeDTO dto) {
        CocktailRecipe recipe = recipeMapper.selectById(dto.getId());
        if (recipe == null) {
            throw new BusinessException("配方不存在");
        }

        BeanUtils.copyProperties(dto, recipe);

        // 将口味标签转为 JSON
        try {
            if (dto.getTasteTags() != null) {
                recipe.setTasteTags(objectMapper.writeValueAsString(dto.getTasteTags()));
            }
        } catch (JsonProcessingException e) {
            throw new BusinessException("口味标签格式错误");
        }

        recipeMapper.updateById(recipe);

        // 更新原料关联（先删后增）
        LambdaQueryWrapper<RecipeIngredient> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(RecipeIngredient::getRecipeId, dto.getId());
        recipeIngredientMapper.delete(wrapper);

        if (dto.getIngredients() != null && !dto.getIngredients().isEmpty()) {
            saveRecipeIngredients(dto.getId(), dto.getIngredients());
        }

        // 重新计算成本价
        updateRecipeCost(dto.getId());
    }

    /**
     * 删除配方（软删除）
     */
    public void deleteRecipe(Long id) {
        CocktailRecipe recipe = recipeMapper.selectById(id);
        if (recipe == null) {
            throw new BusinessException("配方不存在");
        }

        recipe.setStatus(0);
        recipeMapper.updateById(recipe);
    }

    /**
     * 保存配方原料关联
     */
    private void saveRecipeIngredients(Long recipeId, List<RecipeIngredientDTO> ingredients) {
        for (RecipeIngredientDTO dto : ingredients) {
            // 验证原料是否存在
            Ingredient ingredient = ingredientMapper.selectById(dto.getIngredientId());
            if (ingredient == null) {
                throw new BusinessException("原料ID " + dto.getIngredientId() + " 不存在");
            }

            RecipeIngredient ri = new RecipeIngredient();
            ri.setRecipeId(recipeId);
            ri.setIngredientId(dto.getIngredientId());
            ri.setQuantity(dto.getQuantity());
            ri.setUnit(dto.getUnit() != null ? dto.getUnit() : ingredient.getUnit());
            ri.setIsOptional(dto.getIsOptional() != null ? dto.getIsOptional() : 0);
            ri.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0);

            recipeIngredientMapper.insert(ri);
        }
    }

    /**
     * 更新配方成本价（根据原料成本计算）
     */
    private void updateRecipeCost(Long recipeId) {
        List<RecipeIngredientVO> ingredients = getRecipeIngredients(recipeId);

        BigDecimal totalCost = ingredients.stream()
                .filter(vo -> vo.getIsOptional() == 0) // 只计算非可选原料
                .map(vo -> {
                    Ingredient ingredient = ingredientMapper.selectById(vo.getIngredientId());
                    if (ingredient != null && ingredient.getCostPrice() != null) {
                        return ingredient.getCostPrice().multiply(vo.getQuantity());
                    }
                    return BigDecimal.ZERO;
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        CocktailRecipe recipe = new CocktailRecipe();
        recipe.setId(recipeId);
        recipe.setCostPrice(totalCost);
        recipeMapper.updateById(recipe);
    }

    /**
     * 检查配方库存是否充足
     */
    public boolean checkRecipeStock(Long recipeId, Integer quantity) {
        List<RecipeIngredientVO> ingredients = getRecipeIngredients(recipeId);

        for (RecipeIngredientVO vo : ingredients) {
            if (vo.getIsOptional() == 0) { // 必需原料
                BigDecimal needQuantity = vo.getQuantity().multiply(BigDecimal.valueOf(quantity));
                if (vo.getStock().compareTo(needQuantity) < 0) {
                    log.warn("原料 {} 库存不足，需要 {}，当前 {}", vo.getIngredientName(), needQuantity, vo.getStock());
                    return false;
                }
            }
        }

        return true;
    }

    /**
     * 扣减配方原料库存（用于下单）
     */
    @Transactional(rollbackFor = Exception.class)
    public void deductRecipeStock(Long recipeId, Integer quantity) {
        List<RecipeIngredientVO> ingredients = getRecipeIngredients(recipeId);

        for (RecipeIngredientVO vo : ingredients) {
            if (vo.getIsOptional() == 0) { // 必需原料
                BigDecimal needQuantity = vo.getQuantity().multiply(BigDecimal.valueOf(quantity));
                int result = ingredientMapper.deductStock(vo.getIngredientId(), needQuantity);

                if (result == 0) {
                    throw new BusinessException(vo.getIngredientName() + " 库存不足");
                }

                log.info("扣减原料库存：{} -{} {}", vo.getIngredientName(), needQuantity, vo.getUnit());
            }
        }
    }

    /**
     * 获取配方成本价
     */
    public BigDecimal getRecipeCostPrice(Long recipeId) {
        CocktailRecipe recipe = recipeMapper.selectById(recipeId);
        if (recipe == null) {
            throw new BusinessException("配方不存在");
        }
        return recipe.getCostPrice() != null ? recipe.getCostPrice() : BigDecimal.ZERO;
    }
}
