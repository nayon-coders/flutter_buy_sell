import 'dart:async';
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/db/blog_dao.dart';
import 'package:flutterbuyandsell/viewobject/blog.dart';
import 'package:flutter/material.dart';
import 'package:flutterbuyandsell/api/common/ps_resource.dart';
import 'package:flutterbuyandsell/api/common/ps_status.dart';
import 'package:flutterbuyandsell/api/ps_api_service.dart';

import 'Common/ps_repository.dart';

class BlogRepository extends PsRepository {
  BlogRepository(
      {required PsApiService psApiService, required BlogDao blogDao}) {
    _psApiService = psApiService;
    _blogDao = blogDao;
  }

  String primaryKey = 'id';
  PsApiService _psApiService;
  BlogDao _blogDao;

  Future<dynamic> insert(Blog blog) async {
    return _blogDao.insert(primaryKey, blog);
  }

  Future<dynamic> update(Blog blog) async {
    return _blogDao.update(blog);
  }

  Future<dynamic> delete(Blog blog) async {
    return _blogDao.delete(blog);
  }

  Future<dynamic> getAllBlogList(
      StreamController<PsResource<List<Blog>>> blogListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    blogListStream.sink.add(await _blogDao.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<Blog>> _resource =
          await _psApiService.getBlogList(limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        await _blogDao.deleteAll();
        await _blogDao.insertAll(primaryKey, _resource.data!);
        
      }else{
        if (_resource.errorCode == PsConst.ERROR_CODE_10001) {
          await _blogDao.deleteAll();
        }
      }
      blogListStream.sink.add(await _blogDao.getAll());
    }
  }

  Future<dynamic> getNextPageBlogList(
      StreamController<PsResource<List<Blog>>> blogListStream,
      bool isConnectedToInternet,
      int limit,
      int offset,
      PsStatus status,
      {bool isLoadFromServer = true}) async {
    blogListStream.sink.add(await _blogDao.getAll(status: status));

    if (isConnectedToInternet) {
      final PsResource<List<Blog>> _resource =
          await _psApiService.getBlogList(limit, offset);

      if (_resource.status == PsStatus.SUCCESS) {
        await _blogDao.insertAll(primaryKey, _resource.data!);
      }
      blogListStream.sink.add(await _blogDao.getAll());
    }
  }
}
