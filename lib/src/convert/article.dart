import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../site.dart';
import 'api.dart';
import 'align.dart';
import 'image.dart';
import 'gradient.dart';
import 'border.dart';
import 'edge.dart';
import 'shadow.dart';
import 'util.dart';
 
class Article {
  static Future<List<ArticleModel>> getList(dynamic map) async {
    final Map response = await Api.call('articles', {
        'category': map['category'].toString(),
        'status': map['status'].toString(),
        'tag': map['tag'].toString(),
        'order': map['order'].toString(),
        'skip': map['skip'].toString(),
        'limit': map['limit'].toString(),
      });
    if((response is Map) && (response['articles'] is List)) {
      final List<ArticleModel> list = parsePostsForGrid(response['articles']);
      return list;
    }
    return null;
  }

  static Future<Map> getArticle(int id) async {
    final Map response = await Api.call('article', {
        'id': id.toString(),
      });
    if((response is Map) && (response['article'] is Map)) {
      return response['article'];
    }
    return null;
  }

  static List<ArticleModel> parsePostsForGrid(List body) {
    try {
      if((body != null) && (body != null)) {
        return body.map<ArticleModel>((json) => ArticleModel.fromJson(json)).toList();
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return null;
  }
  
  static Widget getGrid(AsyncSnapshot<List<ArticleModel>> snapshot, dynamic map, Function gridClicked) {
    dynamic box = getVal(map,'box'),
      data = getVal(map,'data'),
      dataBox = getVal(data,'box');
    int colMb = getInt(getVal(data,'col.mb'),2);
    EdgeInsets padding = getEdgeInset(getVal(dataBox,'padding')),
      margin = getEdgeInset(getVal(dataBox,'margin')),
      contentPadding = getEdgeInset(getVal(data,'content.padding'));
    TextAlign contentAlign = getAlignText(getVal(data,'content.align'));
    int contentLine = getInt(getVal(data,'content.line'),0);
    String align = getVal(data,'align').toString();
    double width  = getDouble(getVal(data,'width'),80),
      ratio = getRatio(getVal(data,'ratio'));
    Border border = getBorder(getVal(dataBox,'border'));
    BorderRadius radius = getBorderRadius(getVal(dataBox,'border'));
    List<BoxShadow> boxShadow = getBoxShadow(getVal(dataBox,'shadow'));
    Gradient gradient  = getGradient(getVal(dataBox,'bg.color'));
    Color textColor  = getColor(getVal(data,'color'),'000');
    double textSize  = getDouble(getVal(data,'fsize'),Site.fontSize);    
    String colDirect = getVal(data,'col.direct').toString();
    double colHeight  = getDouble(getVal(data,'col.height'),200);
    if(width < 50) {
      width = 50;
    }
    try {
      //print(box);
      return  Container(
        alignment: Alignment.center,    
        decoration: BoxDecoration(
          gradient: getGradient(getVal(box,'bg.color')),
          borderRadius: getBorderRadius(getVal(box,'border')),
          border: getBorder(getVal(box,'border')),
          boxShadow: getBoxShadow(getVal(box,'shadow')),
        ),
        margin: getEdgeInset(getVal(box,'margin')),
        padding: getEdgeInset(getVal(box,'padding')),
        width: double.infinity,
        height: colDirect == 'horizon' ? colHeight : null,
        child: StaggeredGridView.countBuilder(
          primary: false,
          addAutomaticKeepAlives: true,
          crossAxisCount: colDirect == 'horizon' ? 1 : colMb,
          scrollDirection: colDirect == 'horizon' ? Axis.horizontal : Axis.vertical,
          itemCount: snapshot.data.length,
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: ArticleCell(
                snapshot.data[index],
                padding,
                margin,
                border,
                radius,
                boxShadow,
                gradient,
                align,
                width,
                ratio,
                contentAlign,
                contentPadding,
                contentLine,
                textColor,
                textSize,
              ),
              onTap: () => gridClicked(snapshot.data[index]),
            );
          },
          staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        )
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
 
  static Widget circularProgress() {
    return Container(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent)
      )
    );
  }

  static FlatButton retryButton(Function fetch) {
    return FlatButton(
      child: Text(
        "No Internet Connection.\nPlease Retry",
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      onPressed: () => fetch(),
    );
  }
}

class ArticleModel {
  String id;
  String title;
  String url;
  Map image; 
  ArticleModel({this.id, this.title, this.url, this.image}); 
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    try {
      return new ArticleModel(
        id: json['_id'].toString(),
        title: json['title'].toString(),
        url: json['link'].toString(),
        image: getVal(json,'image')
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class ArticleCell extends StatelessWidget {
  const ArticleCell(
    this.cellModel,this.padding,this.margin,this.border,this.radius,this.shadow,this.gradient,  
    this.align,this.width,this.ratio,this.contentAlign,this.contentPadding,this.contentLine,
    this.textColor,this.textSize
  );
  @required
  final ArticleModel cellModel;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Border border;
  final BorderRadius radius;
  final List<BoxShadow> shadow;
  final Gradient gradient;
  final String align;
  final double width;
  final double ratio;
  final TextAlign contentAlign;
  final EdgeInsets contentPadding;
  final int contentLine;
  final Color textColor;
  final double textSize;
 
  @override
  Widget build(BuildContext context) {
    //Site.log.e(contentAlign);
    Widget _image = getImageRatio(cellModel.image, 't', ratio);
    Widget _content = Container(
      padding: contentPadding,       
      margin: EdgeInsets.all(0),
      child: Text(
        cellModel.title,
        textAlign: contentAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: contentLine > 0 ? contentLine : 5,
        style: TextStyle(color: textColor, fontSize: textSize, fontFamily:Site.font, height: 1.5),
      ),
    );

    Widget _child;
    if(align == 'left') {
      _child = Row(            
        children: [
          Container(width: width, child: _image,),
          Expanded(child: _content),
        ],
      );
    } else if(align == 'right') {
      _child = Row(            
        children: [
          Expanded(child: _content),
          Container(width: width, child: _image),
        ],
      );
    } else {
      _child = Column(       
        crossAxisAlignment: CrossAxisAlignment.center,     
        children: [_image, _content],
      );
    }
    try {
      return Container(
          decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          boxShadow: shadow,
        ),
        margin: margin,
        padding: padding,
        child: _child,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}