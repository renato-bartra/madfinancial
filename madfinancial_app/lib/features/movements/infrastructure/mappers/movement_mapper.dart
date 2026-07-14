import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/movement_type.dart';
import '../../domain/entities/submovement.dart';
import '../../domain/entities/tag.dart';
import '../dtos/movement_dto.dart';

extension MovementTypeMapper on MovementTypeDto {
  MovementType toEntity() => MovementType(id: id, description: description);
}

extension CategoryMapper on CategoryDto {
  Category toEntity() {
    return Category(
      id: id,
      isExpenseCategory: isExpenseCategory,
      description: description,
      iconName: iconName,
    );
  }
}

extension AccountMapper on AccountDto {
  Account toEntity() => Account(id: id, description: description);
}

extension TagMapper on TagDto {
  Tag toEntity() => Tag(id: id, description: description);
}

extension SubmovementMapper on SubmovementDto {
  Submovement toEntity() {
    return Submovement(
      id: id,
      description: description,
      amount: amount,
      subcategory: subcategory.toEntity(),
      tags: tags.map((tag) => tag.toEntity()).toList(),
    );
  }
}

extension MovementMapper on MovementDto {
  Movement toEntity() {
    return Movement(
      id: id,
      userId: userId,
      title: title,
      description: description,
      amount: amount,
      accountingDate: accountingDate,
      type: type.toEntity(),
      category: category.toEntity(),
      account: account.toEntity(),
      tags: tags.map((tag) => tag.toEntity()).toList(),
      submovements: submovements
          .map((submovement) => submovement.toEntity())
          .toList(),
    );
  }
}

extension MovementToDto on Movement {
  MovementDto toDto() {
    return MovementDto(
      id: id,
      userId: userId,
      title: title,
      description: description,
      amount: amount,
      accountingDate: accountingDate,
      type: MovementTypeDto(id: type.id, description: type.description),
      category: CategoryDto(
        id: category.id,
        isExpenseCategory: category.isExpenseCategory,
        description: category.description,
        iconName: category.iconName,
      ),
      account: AccountDto(id: account.id, description: account.description),
      tags: tags
          .map((tag) => TagDto(id: tag.id, description: tag.description))
          .toList(),
      submovements: submovements
          .map(
            (sub) => SubmovementDto(
              id: sub.id,
              description: sub.description,
              amount: sub.amount,
              subcategory: CategoryDto(
                id: sub.subcategory.id,
                isExpenseCategory: sub.subcategory.isExpenseCategory,
                description: sub.subcategory.description,
                iconName: sub.subcategory.iconName,
              ),
              tags: sub.tags
                  .map(
                    (tag) => TagDto(id: tag.id, description: tag.description),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
