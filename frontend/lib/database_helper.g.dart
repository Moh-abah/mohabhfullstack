// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_helper.dart';

// ignore_for_file: type=lint
class $OffersTable extends Offers with TableInfo<$OffersTable, Offer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OffersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _merchantIdMeta =
      const VerificationMeta('merchantId');
  @override
  late final GeneratedColumn<String> merchantId = GeneratedColumn<String>(
      'merchant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storeNameMeta =
      const VerificationMeta('storeName');
  @override
  late final GeneratedColumn<String> storeName = GeneratedColumn<String>(
      'store_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
      'images', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
      'expiry_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _likesMeta = const VerificationMeta('likes');
  @override
  late final GeneratedColumn<int> likes = GeneratedColumn<int>(
      'likes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _viewedMeta = const VerificationMeta('viewed');
  @override
  late final GeneratedColumn<bool> viewed = GeneratedColumn<bool>(
      'viewed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("viewed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        merchantId,
        storeName,
        description,
        duration,
        images,
        createdAt,
        expiryDate,
        isActive,
        likes,
        viewed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offers';
  @override
  VerificationContext validateIntegrity(Insertable<Offer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('merchant_id')) {
      context.handle(
          _merchantIdMeta,
          merchantId.isAcceptableOrUnknown(
              data['merchant_id']!, _merchantIdMeta));
    } else if (isInserting) {
      context.missing(_merchantIdMeta);
    }
    if (data.containsKey('store_name')) {
      context.handle(_storeNameMeta,
          storeName.isAcceptableOrUnknown(data['store_name']!, _storeNameMeta));
    } else if (isInserting) {
      context.missing(_storeNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('images')) {
      context.handle(_imagesMeta,
          images.isAcceptableOrUnknown(data['images']!, _imagesMeta));
    } else if (isInserting) {
      context.missing(_imagesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('likes')) {
      context.handle(
          _likesMeta, likes.isAcceptableOrUnknown(data['likes']!, _likesMeta));
    }
    if (data.containsKey('viewed')) {
      context.handle(_viewedMeta,
          viewed.isAcceptableOrUnknown(data['viewed']!, _viewedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Offer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Offer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      merchantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merchant_id'])!,
      storeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      images: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expiry_date']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      likes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}likes'])!,
      viewed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}viewed'])!,
    );
  }

  @override
  $OffersTable createAlias(String alias) {
    return $OffersTable(attachedDatabase, alias);
  }
}

class Offer extends DataClass implements Insertable<Offer> {
  final String id;
  final String merchantId;
  final String storeName;
  final String description;
  final int duration;
  final String images;
  final DateTime? createdAt;
  final DateTime? expiryDate;
  final bool isActive;
  final int likes;
  final bool viewed;
  const Offer(
      {required this.id,
      required this.merchantId,
      required this.storeName,
      required this.description,
      required this.duration,
      required this.images,
      this.createdAt,
      this.expiryDate,
      required this.isActive,
      required this.likes,
      required this.viewed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['merchant_id'] = Variable<String>(merchantId);
    map['store_name'] = Variable<String>(storeName);
    map['description'] = Variable<String>(description);
    map['duration'] = Variable<int>(duration);
    map['images'] = Variable<String>(images);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['likes'] = Variable<int>(likes);
    map['viewed'] = Variable<bool>(viewed);
    return map;
  }

  OffersCompanion toCompanion(bool nullToAbsent) {
    return OffersCompanion(
      id: Value(id),
      merchantId: Value(merchantId),
      storeName: Value(storeName),
      description: Value(description),
      duration: Value(duration),
      images: Value(images),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      isActive: Value(isActive),
      likes: Value(likes),
      viewed: Value(viewed),
    );
  }

  factory Offer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Offer(
      id: serializer.fromJson<String>(json['id']),
      merchantId: serializer.fromJson<String>(json['merchantId']),
      storeName: serializer.fromJson<String>(json['storeName']),
      description: serializer.fromJson<String>(json['description']),
      duration: serializer.fromJson<int>(json['duration']),
      images: serializer.fromJson<String>(json['images']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      likes: serializer.fromJson<int>(json['likes']),
      viewed: serializer.fromJson<bool>(json['viewed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'merchantId': serializer.toJson<String>(merchantId),
      'storeName': serializer.toJson<String>(storeName),
      'description': serializer.toJson<String>(description),
      'duration': serializer.toJson<int>(duration),
      'images': serializer.toJson<String>(images),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'isActive': serializer.toJson<bool>(isActive),
      'likes': serializer.toJson<int>(likes),
      'viewed': serializer.toJson<bool>(viewed),
    };
  }

  Offer copyWith(
          {String? id,
          String? merchantId,
          String? storeName,
          String? description,
          int? duration,
          String? images,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> expiryDate = const Value.absent(),
          bool? isActive,
          int? likes,
          bool? viewed}) =>
      Offer(
        id: id ?? this.id,
        merchantId: merchantId ?? this.merchantId,
        storeName: storeName ?? this.storeName,
        description: description ?? this.description,
        duration: duration ?? this.duration,
        images: images ?? this.images,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
        isActive: isActive ?? this.isActive,
        likes: likes ?? this.likes,
        viewed: viewed ?? this.viewed,
      );
  Offer copyWithCompanion(OffersCompanion data) {
    return Offer(
      id: data.id.present ? data.id.value : this.id,
      merchantId:
          data.merchantId.present ? data.merchantId.value : this.merchantId,
      storeName: data.storeName.present ? data.storeName.value : this.storeName,
      description:
          data.description.present ? data.description.value : this.description,
      duration: data.duration.present ? data.duration.value : this.duration,
      images: data.images.present ? data.images.value : this.images,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      likes: data.likes.present ? data.likes.value : this.likes,
      viewed: data.viewed.present ? data.viewed.value : this.viewed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Offer(')
          ..write('id: $id, ')
          ..write('merchantId: $merchantId, ')
          ..write('storeName: $storeName, ')
          ..write('description: $description, ')
          ..write('duration: $duration, ')
          ..write('images: $images, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('isActive: $isActive, ')
          ..write('likes: $likes, ')
          ..write('viewed: $viewed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, merchantId, storeName, description,
      duration, images, createdAt, expiryDate, isActive, likes, viewed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Offer &&
          other.id == this.id &&
          other.merchantId == this.merchantId &&
          other.storeName == this.storeName &&
          other.description == this.description &&
          other.duration == this.duration &&
          other.images == this.images &&
          other.createdAt == this.createdAt &&
          other.expiryDate == this.expiryDate &&
          other.isActive == this.isActive &&
          other.likes == this.likes &&
          other.viewed == this.viewed);
}

class OffersCompanion extends UpdateCompanion<Offer> {
  final Value<String> id;
  final Value<String> merchantId;
  final Value<String> storeName;
  final Value<String> description;
  final Value<int> duration;
  final Value<String> images;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> expiryDate;
  final Value<bool> isActive;
  final Value<int> likes;
  final Value<bool> viewed;
  final Value<int> rowid;
  const OffersCompanion({
    this.id = const Value.absent(),
    this.merchantId = const Value.absent(),
    this.storeName = const Value.absent(),
    this.description = const Value.absent(),
    this.duration = const Value.absent(),
    this.images = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.likes = const Value.absent(),
    this.viewed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OffersCompanion.insert({
    required String id,
    required String merchantId,
    required String storeName,
    required String description,
    required int duration,
    required String images,
    this.createdAt = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.likes = const Value.absent(),
    this.viewed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        merchantId = Value(merchantId),
        storeName = Value(storeName),
        description = Value(description),
        duration = Value(duration),
        images = Value(images);
  static Insertable<Offer> custom({
    Expression<String>? id,
    Expression<String>? merchantId,
    Expression<String>? storeName,
    Expression<String>? description,
    Expression<int>? duration,
    Expression<String>? images,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiryDate,
    Expression<bool>? isActive,
    Expression<int>? likes,
    Expression<bool>? viewed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (merchantId != null) 'merchant_id': merchantId,
      if (storeName != null) 'store_name': storeName,
      if (description != null) 'description': description,
      if (duration != null) 'duration': duration,
      if (images != null) 'images': images,
      if (createdAt != null) 'created_at': createdAt,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (isActive != null) 'is_active': isActive,
      if (likes != null) 'likes': likes,
      if (viewed != null) 'viewed': viewed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OffersCompanion copyWith(
      {Value<String>? id,
      Value<String>? merchantId,
      Value<String>? storeName,
      Value<String>? description,
      Value<int>? duration,
      Value<String>? images,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? expiryDate,
      Value<bool>? isActive,
      Value<int>? likes,
      Value<bool>? viewed,
      Value<int>? rowid}) {
    return OffersCompanion(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      storeName: storeName ?? this.storeName,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      likes: likes ?? this.likes,
      viewed: viewed ?? this.viewed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (merchantId.present) {
      map['merchant_id'] = Variable<String>(merchantId.value);
    }
    if (storeName.present) {
      map['store_name'] = Variable<String>(storeName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (likes.present) {
      map['likes'] = Variable<int>(likes.value);
    }
    if (viewed.present) {
      map['viewed'] = Variable<bool>(viewed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OffersCompanion(')
          ..write('id: $id, ')
          ..write('merchantId: $merchantId, ')
          ..write('storeName: $storeName, ')
          ..write('description: $description, ')
          ..write('duration: $duration, ')
          ..write('images: $images, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('isActive: $isActive, ')
          ..write('likes: $likes, ')
          ..write('viewed: $viewed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineActionsTable extends OfflineActions
    with TableInfo<$OfflineActionsTable, OfflineAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _offerIdMeta =
      const VerificationMeta('offerId');
  @override
  late final GeneratedColumn<String> offerId = GeneratedColumn<String>(
      'offer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, actionType, offerId, userId, username, data, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_actions';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineAction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('offer_id')) {
      context.handle(_offerIdMeta,
          offerId.isAcceptableOrUnknown(data['offer_id']!, _offerIdMeta));
    } else if (isInserting) {
      context.missing(_offerIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      offerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}offer_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $OfflineActionsTable createAlias(String alias) {
    return $OfflineActionsTable(attachedDatabase, alias);
  }
}

class OfflineAction extends DataClass implements Insertable<OfflineAction> {
  final int id;
  final String actionType;
  final String offerId;
  final String userId;
  final String username;
  final String? data;
  final DateTime createdAt;
  final bool synced;
  const OfflineAction(
      {required this.id,
      required this.actionType,
      required this.offerId,
      required this.userId,
      required this.username,
      this.data,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['offer_id'] = Variable<String>(offerId);
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  OfflineActionsCompanion toCompanion(bool nullToAbsent) {
    return OfflineActionsCompanion(
      id: Value(id),
      actionType: Value(actionType),
      offerId: Value(offerId),
      userId: Value(userId),
      username: Value(username),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineAction(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      offerId: serializer.fromJson<String>(json['offerId']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      data: serializer.fromJson<String?>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'offerId': serializer.toJson<String>(offerId),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'data': serializer.toJson<String?>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  OfflineAction copyWith(
          {int? id,
          String? actionType,
          String? offerId,
          String? userId,
          String? username,
          Value<String?> data = const Value.absent(),
          DateTime? createdAt,
          bool? synced}) =>
      OfflineAction(
        id: id ?? this.id,
        actionType: actionType ?? this.actionType,
        offerId: offerId ?? this.offerId,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        data: data.present ? data.value : this.data,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  OfflineAction copyWithCompanion(OfflineActionsCompanion data) {
    return OfflineAction(
      id: data.id.present ? data.id.value : this.id,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      offerId: data.offerId.present ? data.offerId.value : this.offerId,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineAction(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('offerId: $offerId, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, actionType, offerId, userId, username, data, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineAction &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.offerId == this.offerId &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class OfflineActionsCompanion extends UpdateCompanion<OfflineAction> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> offerId;
  final Value<String> userId;
  final Value<String> username;
  final Value<String?> data;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const OfflineActionsCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.offerId = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  OfflineActionsCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String offerId,
    required String userId,
    required String username,
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  })  : actionType = Value(actionType),
        offerId = Value(offerId),
        userId = Value(userId),
        username = Value(username);
  static Insertable<OfflineAction> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? offerId,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (offerId != null) 'offer_id': offerId,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  OfflineActionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? actionType,
      Value<String>? offerId,
      Value<String>? userId,
      Value<String>? username,
      Value<String?>? data,
      Value<DateTime>? createdAt,
      Value<bool>? synced}) {
    return OfflineActionsCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      offerId: offerId ?? this.offerId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (offerId.present) {
      map['offer_id'] = Variable<String>(offerId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineActionsCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('offerId: $offerId, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $OfflineCommentsTable extends OfflineComments
    with TableInfo<$OfflineCommentsTable, OfferComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _offerIdMeta =
      const VerificationMeta('offerId');
  @override
  late final GeneratedColumn<String> offerId = GeneratedColumn<String>(
      'offer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, offerId, userId, username, comment, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_comments';
  @override
  VerificationContext validateIntegrity(Insertable<OfferComment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('offer_id')) {
      context.handle(_offerIdMeta,
          offerId.isAcceptableOrUnknown(data['offer_id']!, _offerIdMeta));
    } else if (isInserting) {
      context.missing(_offerIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfferComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfferComment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      offerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}offer_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OfflineCommentsTable createAlias(String alias) {
    return $OfflineCommentsTable(attachedDatabase, alias);
  }
}

class OfferComment extends DataClass implements Insertable<OfferComment> {
  final int id;
  final String offerId;
  final String userId;
  final String username;
  final String comment;
  final DateTime createdAt;
  const OfferComment(
      {required this.id,
      required this.offerId,
      required this.userId,
      required this.username,
      required this.comment,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['offer_id'] = Variable<String>(offerId);
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    map['comment'] = Variable<String>(comment);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OfflineCommentsCompanion toCompanion(bool nullToAbsent) {
    return OfflineCommentsCompanion(
      id: Value(id),
      offerId: Value(offerId),
      userId: Value(userId),
      username: Value(username),
      comment: Value(comment),
      createdAt: Value(createdAt),
    );
  }

  factory OfferComment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfferComment(
      id: serializer.fromJson<int>(json['id']),
      offerId: serializer.fromJson<String>(json['offerId']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      comment: serializer.fromJson<String>(json['comment']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'offerId': serializer.toJson<String>(offerId),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'comment': serializer.toJson<String>(comment),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OfferComment copyWith(
          {int? id,
          String? offerId,
          String? userId,
          String? username,
          String? comment,
          DateTime? createdAt}) =>
      OfferComment(
        id: id ?? this.id,
        offerId: offerId ?? this.offerId,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
      );
  OfferComment copyWithCompanion(OfflineCommentsCompanion data) {
    return OfferComment(
      id: data.id.present ? data.id.value : this.id,
      offerId: data.offerId.present ? data.offerId.value : this.offerId,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      comment: data.comment.present ? data.comment.value : this.comment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfferComment(')
          ..write('id: $id, ')
          ..write('offerId: $offerId, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, offerId, userId, username, comment, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfferComment &&
          other.id == this.id &&
          other.offerId == this.offerId &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.comment == this.comment &&
          other.createdAt == this.createdAt);
}

class OfflineCommentsCompanion extends UpdateCompanion<OfferComment> {
  final Value<int> id;
  final Value<String> offerId;
  final Value<String> userId;
  final Value<String> username;
  final Value<String> comment;
  final Value<DateTime> createdAt;
  const OfflineCommentsCompanion({
    this.id = const Value.absent(),
    this.offerId = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OfflineCommentsCompanion.insert({
    this.id = const Value.absent(),
    required String offerId,
    required String userId,
    required String username,
    required String comment,
    this.createdAt = const Value.absent(),
  })  : offerId = Value(offerId),
        userId = Value(userId),
        username = Value(username),
        comment = Value(comment);
  static Insertable<OfferComment> custom({
    Expression<int>? id,
    Expression<String>? offerId,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? comment,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (offerId != null) 'offer_id': offerId,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OfflineCommentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? offerId,
      Value<String>? userId,
      Value<String>? username,
      Value<String>? comment,
      Value<DateTime>? createdAt}) {
    return OfflineCommentsCompanion(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (offerId.present) {
      map['offer_id'] = Variable<String>(offerId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineCommentsCompanion(')
          ..write('id: $id, ')
          ..write('offerId: $offerId, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<int> ownerId = GeneratedColumn<int>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, customerId, ownerId, status, createdAt, updatedAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(Insertable<Chat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}owner_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class Chat extends DataClass implements Insertable<Chat> {
  final String id;
  final int customerId;
  final int ownerId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const Chat(
      {required this.id,
      required this.customerId,
      required this.ownerId,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<int>(customerId);
    map['owner_id'] = Variable<int>(ownerId);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      ownerId: Value(ownerId),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chat(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      ownerId: serializer.fromJson<int>(json['ownerId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<int>(customerId),
      'ownerId': serializer.toJson<int>(ownerId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Chat copyWith(
          {String? id,
          int? customerId,
          int? ownerId,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced}) =>
      Chat(
        id: id ?? this.id,
        customerId: customerId ?? this.customerId,
        ownerId: ownerId ?? this.ownerId,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
      );
  Chat copyWithCompanion(ChatsCompanion data) {
    return Chat(
      id: data.id.present ? data.id.value : this.id,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('ownerId: $ownerId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, customerId, ownerId, status, createdAt, updatedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.ownerId == this.ownerId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<String> id;
  final Value<int> customerId;
  final Value<int> ownerId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatsCompanion.insert({
    required String id,
    required int customerId,
    required int ownerId,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        customerId = Value(customerId),
        ownerId = Value(ownerId);
  static Insertable<Chat> custom({
    Expression<String>? id,
    Expression<int>? customerId,
    Expression<int>? ownerId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (ownerId != null) 'owner_id': ownerId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatsCompanion copyWith(
      {Value<String>? id,
      Value<int>? customerId,
      Value<int>? ownerId,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return ChatsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<int>(ownerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('ownerId: $ownerId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
      'chat_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('text'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
      'read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, chatId, senderId, content, messageType, createdAt, read, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('read')) {
      context.handle(
          _readMeta, read.isAcceptableOrUnknown(data['read']!, _readMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chatId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sender_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      read: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String chatId;
  final int senderId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final bool read;
  final bool synced;
  const Message(
      {required this.id,
      required this.chatId,
      required this.senderId,
      required this.content,
      required this.messageType,
      required this.createdAt,
      required this.read,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_id'] = Variable<String>(chatId);
    map['sender_id'] = Variable<int>(senderId);
    map['content'] = Variable<String>(content);
    map['message_type'] = Variable<String>(messageType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['read'] = Variable<bool>(read);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      content: Value(content),
      messageType: Value(messageType),
      createdAt: Value(createdAt),
      read: Value(read),
      synced: Value(synced),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      chatId: serializer.fromJson<String>(json['chatId']),
      senderId: serializer.fromJson<int>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      messageType: serializer.fromJson<String>(json['messageType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      read: serializer.fromJson<bool>(json['read']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatId': serializer.toJson<String>(chatId),
      'senderId': serializer.toJson<int>(senderId),
      'content': serializer.toJson<String>(content),
      'messageType': serializer.toJson<String>(messageType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'read': serializer.toJson<bool>(read),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Message copyWith(
          {String? id,
          String? chatId,
          int? senderId,
          String? content,
          String? messageType,
          DateTime? createdAt,
          bool? read,
          bool? synced}) =>
      Message(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        senderId: senderId ?? this.senderId,
        content: content ?? this.content,
        messageType: messageType ?? this.messageType,
        createdAt: createdAt ?? this.createdAt,
        read: read ?? this.read,
        synced: synced ?? this.synced,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      read: data.read.present ? data.read.value : this.read,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('createdAt: $createdAt, ')
          ..write('read: $read, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, chatId, senderId, content, messageType, createdAt, read, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.messageType == this.messageType &&
          other.createdAt == this.createdAt &&
          other.read == this.read &&
          other.synced == this.synced);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> chatId;
  final Value<int> senderId;
  final Value<String> content;
  final Value<String> messageType;
  final Value<DateTime> createdAt;
  final Value<bool> read;
  final Value<bool> synced;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.messageType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.read = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String chatId,
    required int senderId,
    required String content,
    this.messageType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.read = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chatId = Value(chatId),
        senderId = Value(senderId),
        content = Value(content);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? chatId,
    Expression<int>? senderId,
    Expression<String>? content,
    Expression<String>? messageType,
    Expression<DateTime>? createdAt,
    Expression<bool>? read,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (messageType != null) 'message_type': messageType,
      if (createdAt != null) 'created_at': createdAt,
      if (read != null) 'read': read,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? chatId,
      Value<int>? senderId,
      Value<String>? content,
      Value<String>? messageType,
      Value<DateTime>? createdAt,
      Value<bool>? read,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('messageType: $messageType, ')
          ..write('createdAt: $createdAt, ')
          ..write('read: $read, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OffersTable offers = $OffersTable(this);
  late final $OfflineActionsTable offlineActions = $OfflineActionsTable(this);
  late final $OfflineCommentsTable offlineComments =
      $OfflineCommentsTable(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [offers, offlineActions, offlineComments, chats, messages];
}

typedef $$OffersTableCreateCompanionBuilder = OffersCompanion Function({
  required String id,
  required String merchantId,
  required String storeName,
  required String description,
  required int duration,
  required String images,
  Value<DateTime?> createdAt,
  Value<DateTime?> expiryDate,
  Value<bool> isActive,
  Value<int> likes,
  Value<bool> viewed,
  Value<int> rowid,
});
typedef $$OffersTableUpdateCompanionBuilder = OffersCompanion Function({
  Value<String> id,
  Value<String> merchantId,
  Value<String> storeName,
  Value<String> description,
  Value<int> duration,
  Value<String> images,
  Value<DateTime?> createdAt,
  Value<DateTime?> expiryDate,
  Value<bool> isActive,
  Value<int> likes,
  Value<bool> viewed,
  Value<int> rowid,
});

class $$OffersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OffersTable,
    Offer,
    $$OffersTableFilterComposer,
    $$OffersTableOrderingComposer,
    $$OffersTableCreateCompanionBuilder,
    $$OffersTableUpdateCompanionBuilder> {
  $$OffersTableTableManager(_$AppDatabase db, $OffersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OffersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OffersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> merchantId = const Value.absent(),
            Value<String> storeName = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<String> images = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> likes = const Value.absent(),
            Value<bool> viewed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OffersCompanion(
            id: id,
            merchantId: merchantId,
            storeName: storeName,
            description: description,
            duration: duration,
            images: images,
            createdAt: createdAt,
            expiryDate: expiryDate,
            isActive: isActive,
            likes: likes,
            viewed: viewed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String merchantId,
            required String storeName,
            required String description,
            required int duration,
            required String images,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> likes = const Value.absent(),
            Value<bool> viewed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OffersCompanion.insert(
            id: id,
            merchantId: merchantId,
            storeName: storeName,
            description: description,
            duration: duration,
            images: images,
            createdAt: createdAt,
            expiryDate: expiryDate,
            isActive: isActive,
            likes: likes,
            viewed: viewed,
            rowid: rowid,
          ),
        ));
}

class $$OffersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $OffersTable> {
  $$OffersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get merchantId => $state.composableBuilder(
      column: $state.table.merchantId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get storeName => $state.composableBuilder(
      column: $state.table.storeName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get images => $state.composableBuilder(
      column: $state.table.images,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get expiryDate => $state.composableBuilder(
      column: $state.table.expiryDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get likes => $state.composableBuilder(
      column: $state.table.likes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get viewed => $state.composableBuilder(
      column: $state.table.viewed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OffersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $OffersTable> {
  $$OffersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get merchantId => $state.composableBuilder(
      column: $state.table.merchantId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get storeName => $state.composableBuilder(
      column: $state.table.storeName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get images => $state.composableBuilder(
      column: $state.table.images,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get expiryDate => $state.composableBuilder(
      column: $state.table.expiryDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get likes => $state.composableBuilder(
      column: $state.table.likes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get viewed => $state.composableBuilder(
      column: $state.table.viewed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$OfflineActionsTableCreateCompanionBuilder = OfflineActionsCompanion
    Function({
  Value<int> id,
  required String actionType,
  required String offerId,
  required String userId,
  required String username,
  Value<String?> data,
  Value<DateTime> createdAt,
  Value<bool> synced,
});
typedef $$OfflineActionsTableUpdateCompanionBuilder = OfflineActionsCompanion
    Function({
  Value<int> id,
  Value<String> actionType,
  Value<String> offerId,
  Value<String> userId,
  Value<String> username,
  Value<String?> data,
  Value<DateTime> createdAt,
  Value<bool> synced,
});

class $$OfflineActionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineActionsTable,
    OfflineAction,
    $$OfflineActionsTableFilterComposer,
    $$OfflineActionsTableOrderingComposer,
    $$OfflineActionsTableCreateCompanionBuilder,
    $$OfflineActionsTableUpdateCompanionBuilder> {
  $$OfflineActionsTableTableManager(
      _$AppDatabase db, $OfflineActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OfflineActionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OfflineActionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> offerId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String?> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              OfflineActionsCompanion(
            id: id,
            actionType: actionType,
            offerId: offerId,
            userId: userId,
            username: username,
            data: data,
            createdAt: createdAt,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String actionType,
            required String offerId,
            required String userId,
            required String username,
            Value<String?> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              OfflineActionsCompanion.insert(
            id: id,
            actionType: actionType,
            offerId: offerId,
            userId: userId,
            username: username,
            data: data,
            createdAt: createdAt,
            synced: synced,
          ),
        ));
}

class $$OfflineActionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $OfflineActionsTable> {
  $$OfflineActionsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get actionType => $state.composableBuilder(
      column: $state.table.actionType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get offerId => $state.composableBuilder(
      column: $state.table.offerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get username => $state.composableBuilder(
      column: $state.table.username,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get synced => $state.composableBuilder(
      column: $state.table.synced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OfflineActionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $OfflineActionsTable> {
  $$OfflineActionsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get actionType => $state.composableBuilder(
      column: $state.table.actionType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get offerId => $state.composableBuilder(
      column: $state.table.offerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get username => $state.composableBuilder(
      column: $state.table.username,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get synced => $state.composableBuilder(
      column: $state.table.synced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$OfflineCommentsTableCreateCompanionBuilder = OfflineCommentsCompanion
    Function({
  Value<int> id,
  required String offerId,
  required String userId,
  required String username,
  required String comment,
  Value<DateTime> createdAt,
});
typedef $$OfflineCommentsTableUpdateCompanionBuilder = OfflineCommentsCompanion
    Function({
  Value<int> id,
  Value<String> offerId,
  Value<String> userId,
  Value<String> username,
  Value<String> comment,
  Value<DateTime> createdAt,
});

class $$OfflineCommentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineCommentsTable,
    OfferComment,
    $$OfflineCommentsTableFilterComposer,
    $$OfflineCommentsTableOrderingComposer,
    $$OfflineCommentsTableCreateCompanionBuilder,
    $$OfflineCommentsTableUpdateCompanionBuilder> {
  $$OfflineCommentsTableTableManager(
      _$AppDatabase db, $OfflineCommentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OfflineCommentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OfflineCommentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> offerId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> comment = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OfflineCommentsCompanion(
            id: id,
            offerId: offerId,
            userId: userId,
            username: username,
            comment: comment,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String offerId,
            required String userId,
            required String username,
            required String comment,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OfflineCommentsCompanion.insert(
            id: id,
            offerId: offerId,
            userId: userId,
            username: username,
            comment: comment,
            createdAt: createdAt,
          ),
        ));
}

class $$OfflineCommentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $OfflineCommentsTable> {
  $$OfflineCommentsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get offerId => $state.composableBuilder(
      column: $state.table.offerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get username => $state.composableBuilder(
      column: $state.table.username,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get comment => $state.composableBuilder(
      column: $state.table.comment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OfflineCommentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $OfflineCommentsTable> {
  $$OfflineCommentsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get offerId => $state.composableBuilder(
      column: $state.table.offerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get username => $state.composableBuilder(
      column: $state.table.username,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get comment => $state.composableBuilder(
      column: $state.table.comment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ChatsTableCreateCompanionBuilder = ChatsCompanion Function({
  required String id,
  required int customerId,
  required int ownerId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$ChatsTableUpdateCompanionBuilder = ChatsCompanion Function({
  Value<String> id,
  Value<int> customerId,
  Value<int> ownerId,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$ChatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatsTable,
    Chat,
    $$ChatsTableFilterComposer,
    $$ChatsTableOrderingComposer,
    $$ChatsTableCreateCompanionBuilder,
    $$ChatsTableUpdateCompanionBuilder> {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChatsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChatsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> customerId = const Value.absent(),
            Value<int> ownerId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatsCompanion(
            id: id,
            customerId: customerId,
            ownerId: ownerId,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int customerId,
            required int ownerId,
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatsCompanion.insert(
            id: id,
            customerId: customerId,
            ownerId: ownerId,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
        ));
}

class $$ChatsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get customerId => $state.composableBuilder(
      column: $state.table.customerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get ownerId => $state.composableBuilder(
      column: $state.table.ownerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get synced => $state.composableBuilder(
      column: $state.table.synced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ChatsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get customerId => $state.composableBuilder(
      column: $state.table.customerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get ownerId => $state.composableBuilder(
      column: $state.table.ownerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get synced => $state.composableBuilder(
      column: $state.table.synced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String chatId,
  required int senderId,
  required String content,
  Value<String> messageType,
  Value<DateTime> createdAt,
  Value<bool> read,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> chatId,
  Value<int> senderId,
  Value<String> content,
  Value<String> messageType,
  Value<DateTime> createdAt,
  Value<bool> read,
  Value<bool> synced,
  Value<int> rowid,
});

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MessagesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> chatId = const Value.absent(),
            Value<int> senderId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> messageType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> read = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            chatId: chatId,
            senderId: senderId,
            content: content,
            messageType: messageType,
            createdAt: createdAt,
            read: read,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String chatId,
            required int senderId,
            required String content,
            Value<String> messageType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> read = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            chatId: chatId,
            senderId: senderId,
            content: content,
            messageType: messageType,
            createdAt: createdAt,
            read: read,
            synced: synced,
            rowid: rowid,
          ),
        ));
}

class $$MessagesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get chatId => $state.composableBuilder(
      column: $state.table.chatId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get senderId => $state.composableBuilder(
      column: $state.table.senderId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get messageType => $state.composableBuilder(
      column: $state.table.messageType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get read => $state.composableBuilder(
      column: $state.table.read,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get synced => $state.composableBuilder(
      column: $state.table.synced,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MessagesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get chatId => $state.composableBuilder(
      column: $state.table.chatId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get senderId => $state.composableBuilder(
      column: $state.table.senderId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get messageType => $state.composableBuilder(
      column: $state.table.messageType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get read => $state.composableBuilder(
      column: $state.table.read,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get synced => $state.composableBuilder(
      column: $state.table.synced,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OffersTableTableManager get offers =>
      $$OffersTableTableManager(_db, _db.offers);
  $$OfflineActionsTableTableManager get offlineActions =>
      $$OfflineActionsTableTableManager(_db, _db.offlineActions);
  $$OfflineCommentsTableTableManager get offlineComments =>
      $$OfflineCommentsTableTableManager(_db, _db.offlineComments);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
}
