import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_shop/utils/provider_modal.dart';
import 'package:flutter_shop/utils/service_method.dart';
import 'package:provider/provider.dart';
import '../routers/application.dart';

int pageSize = 10;
int pageNum = 0;
List<Map> articleList = [];
int _count = 10; //一次显示的条数

class ShowArticleList extends StatefulWidget {
  final String url;
  final String searchContent;
  final int articleTypeId;
  // ShowArticleList({Key: key, this.url}) : super(Key: key);
  const ShowArticleList(
      {Key key, this.searchContent, this.url, this.articleTypeId})
      : super(key: key);

  @override
  _ShowArticleListState createState() =>
      _ShowArticleListState(url, searchContent, articleTypeId);
}

class _ShowArticleListState extends State<ShowArticleList> {
  final String url;

  final String searchContent;
  final int articleTypeId;

  _ShowArticleListState(this.url, this.searchContent, this.articleTypeId);

  @override
  void initState() {
    super.initState();
    setState(() {
      _count = 10;
      pageNum = 0;
    });
    var formPage = {
      'pageSize': pageSize,
      'pageNum': pageNum,
      'searchContent': searchContent,
      'articleTypeId': articleTypeId
    };
    try {
      DioUtil.request(url, formData: formPage).then((val) {
        var data = json.decode(val.toString());
        // print(data['data']['rows']);
        List<Map> newArticlList = (data['data']['rows'] as List).cast();
        setState(() {
          articleList.clear();
          articleList.addAll(newArticlList);
          pageNum++;
          // _count += 10;
        });
        // print('hard');
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ArticleList(
                index: index,
              );
            },
            childCount: _count,
          ),
        ),
      ],
      // onRefresh: () async {
      //   setState(() {
      //     pageNum = 0;
      //     _count = 0;
      //     articleList.clear();
      //   });
      //   print('开始加载');
      //   var formPage = {'pageNum': pageNum, 'pageSize': pageSize};
      //   await request('getArticleList', formData: formPage).then((val) {
      //     var data = json.decode(val.toString());
      //     List<Map> newArticlesList = (data['data']['rows'] as List).cast();
      //     setState(() {
      //       articleList.addAll(newArticlesList);
      //       // _preCount = 10;
      //     });
      //     print(articleList.length);
      //   });
      // },
      onLoad: () async {
        print('开始加载更多');
        var formPage = {
          'pageNum': pageNum,
          'pageSize': pageSize,
          'searchContent': searchContent
        };
        await DioUtil.request(url, formData: formPage).then((val) {
          var data = json.decode(val.toString());
          List<Map> newArticlesList = (data['data']['rows'] as List).cast();
          setState(() {
            articleList.addAll(newArticlesList);
            pageNum++;
            _count += (data['data']['rows'] as List).length;
          });
        });
      },
    );
  }
}

//文章列表展示控件
class ArticleList extends StatelessWidget {
  final int index;
  // ArticleList(this.index);

  // List<Map> articleList;
  const ArticleList({
    Key key,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerModal = Provider.of<IsLoginModal>(context);
    if (articleList.length != 0) {
      print(index);
      //Card本身似乎没有点击事件，使用 InkWell 包裹使其能够触发点击事件
      return InkWell(
        onTap: () {
          Application.router.navigateTo(
            context,
            '/detail?id=${articleList[index]['id']}&userId=${providerModal.userId}',
            transition: TransitionType.fadeIn,
          );
        },
        child: Card(
          elevation: 5.0,
          child: Container(
            height: 180.0,
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Text(articleList[index]['user']['username']),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child:
                              Text(articleList[index]['blog_type']['typename']),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    articleList[index]['title'],
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  alignment: Alignment.topLeft,
                  child: Text('这里会有一些简介~~~~~~~~'),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.thumb_up,
                        size: 12,
                      ),
                      Text('666'),
                      Text('   '),
                      Icon(
                        Icons.message,
                        size: 12,
                      ),
                      Text('233'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Text(' '),
      );
    }
  }
}
