library flutter_sticky_table;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 默认的列宽度
const defaultColumnWidth = 64.0;

/// 默认的行高
const defaultRowHeight = 64.0;

/// 默认的padding
const defaultPadding = 12.0;

/// 默认的头部背景
const defaultHeaderBackgroundColor = Color.fromRGBO(220, 220, 220, 1.0);

/// 默认的内容背景
const defaultBodyBackgroundColor = Color.fromRGBO(225, 225, 225, 1.0);

/// 列的渲染器
/// context: 上下文
/// value: 表格内容
/// key: 列的key
typedef ColumnRender = Widget Function(BuildContext context, dynamic value);

/// 列属性配置
class ColumnsProps {
  /// 列头显示的标题
  final String title;

  /// 列所在的字段索引
  final String dataIndex;

  /// 列的宽度，默认为defaultColumnWidth
  final double width;

  /// 列的高度，默认为defaultRowHeight
//  final double height;

  /// 自定义绘制表格内容（不包括表头）
  final ColumnRender render;

  /// 表格内容所在的定位方式（包括表头）
  final Alignment alignment;

  /// 表格内容的背景颜色
  final Color color;

  /// 头部背景颜色
  final Color headColor;

  ColumnsProps(this.title, this.dataIndex,
      {this.width = 0.0,
      this.render,
//      this.height = 0.0,
      this.alignment = Alignment.centerLeft,
      this.headColor,
      this.color});
}

/// 表格
class StickyTable extends StatefulWidget {
  /// 固定列的数量（从0列开始计算）
  final int stickyColumnCount;

  /// 列的属性配置
  final List<ColumnsProps> columns;

  /// 表格内容，列表
  final List<dynamic> data;

  /// 表头的背景颜色
  final Color headerBackgroundColor;

  /// 表格内容的背景颜色
  final Color bodyBackgroundColor;

  /// 是否显示边框
  final bool showBorder;

  StickyTable({
    this.stickyColumnCount = 0,
    this.columns,
    this.data,
    this.headerBackgroundColor = defaultHeaderBackgroundColor,
    this.bodyBackgroundColor = defaultBodyBackgroundColor,
    this.showBorder = false,
  });

  @override
  _StickyTableState createState() => _StickyTableState();
}

class _StickyTableState extends State<StickyTable> {
  ScrollController headerController = new ScrollController();
  ScrollController bodyController = new ScrollController();

  ///
  /// 头部滚动监听器
  /// 用于计算当前header的偏移量，然后设置body的偏移量
  /// 调整body偏移位置的时候需要删除body的监听，否则会死锁监听滚动（jumpTo函数会调用notifyListener）
  ///
  void headerListener() {
    bodyController.removeListener(bodyListener);
    bodyController.jumpTo(headerController.offset);
    bodyController.addListener(bodyListener);
  }

  ///
  /// body滚动监听器
  /// 用于计算当前body的偏移量，然后设置head的偏移量
  /// 调整head偏移位置的时候需要删除head的监听，否则会死锁监听滚动（jumpTo函数会调用notifyListener）
  ///
  void bodyListener() {
    headerController.removeListener(headerListener);
    headerController.jumpTo(bodyController.offset);
    headerController.addListener(headerListener);
  }

  @override
  void initState() {
    super.initState();

    ///
    /// 监听滚动，实现header和body同步滚动
    ///
    headerController.addListener(headerListener);
    bodyController.addListener(bodyListener);
  }

  @override
  Widget build(BuildContext context) {
    Widget sticky = StickyHeader(
      header: TableHeader(
          scrollController: headerController,
          stickyColumnCount: widget.stickyColumnCount,
          columns: widget.columns,
          showBorder: widget.showBorder,
          backgroundColor: widget.headerBackgroundColor),
      content: TableBody(
          scrollController: bodyController,
          stickyColumnCount: widget.stickyColumnCount,
          columns: widget.columns,
          showBorder: widget.showBorder,
          data: widget.data,
          backgroundColor: widget.bodyBackgroundColor),
    );

    return null != Scrollable.of(context)
        ? sticky
        : new SingleChildScrollView(
            child: sticky,
          );
  }
}

/// 表格内容信息
class TableBody extends StatefulWidget {
  final ScrollController scrollController;

  final int stickyColumnCount;

  final List<ColumnsProps> columns;

  final List<dynamic> data;

  final bool showBorder;

  final Color backgroundColor;

  const TableBody(
      {Key key,
      this.scrollController,
      this.columns,
      this.data,
      this.stickyColumnCount = 0,
      this.showBorder = false,
      this.backgroundColor})
      : super(key: key);

  @override
  _TableBodyState createState() => _TableBodyState();
}

class _TableBodyState extends State<TableBody> {
  List<double> maxHeights = [];

  bool mounted = false;

  @override
  void initState() {
    super.initState();
    mounted = true;

    widget.data.forEach((_) {
      maxHeights.add(0);
    });
  }

  @override
  void dispose() {
    mounted = false;

    super.dispose();
  }

  @override
  void didUpdateWidget(TableBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 如果数据没变化则不更新
    if (oldWidget.data == widget.data && oldWidget.columns == widget.columns) {
      return;
    }

    /// 数据变化后重新计算最大高度
    maxHeights = [];
    widget.data.forEach((_) {
      maxHeights.add(0);
    });
    if (mounted) setState(() {});
  }

  /// 每个单元格控件
  Widget getCell(ColumnsProps c) {
    List<Widget> rows = [];
    for (var i = 0; i < widget.data.length; i++) {
      dynamic value = widget.data[i];
      rows.add(TableCell(
        render: null != c.render
            ? c.render(context, value)
            : Text(value[c.dataIndex] ?? ''),
        backgroundColor: c.color,
        width: c.width > 0 ? c.width : defaultColumnWidth,
        showBorder: widget.showBorder,
        alignment: c.alignment,
        height: maxHeights.length > i ? maxHeights[i] : null,
        onSized: (size) {
          if (maxHeights[i] == size.height) {
            return;
          }

          /// 取出每行最大高度
          maxHeights[i] = max(maxHeights[i], size.height);
          if (maxHeights.every((h) => h > 0)) {
            /// 重新绘制每个单元格的高度
            if (mounted) setState(() {});
          }
        },
      ));
    }
    return new Container(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
      color: widget.backgroundColor ?? defaultBodyBackgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (null == widget.columns ||
        widget.columns.length == 0 ||
        widget.data == null ||
        widget.data.length == 0) {
      return new Container();
    }

    return new LayoutBuilder(
        builder: (BuildContext c, BoxConstraints constraints) {
      int _stickyColumnCount =
          min(widget.stickyColumnCount, widget.columns.length);

      /// 固定的列
      List<ColumnsProps> stickyColumnProps = _stickyColumnCount > 0
          ? widget.columns.sublist(0, _stickyColumnCount)
          : [];

      /// 不固定的列
      List<ColumnsProps> unStickyColumns = _stickyColumnCount > 0
          ? widget.columns.sublist(_stickyColumnCount)
          : widget.columns;

      double stickyWidth = 0.0;
      List<Widget> stickyColumnWidgets =
          stickyColumnProps.map((ColumnsProps c) {
        stickyWidth += c.width > 0 ? c.width : defaultColumnWidth;
        return getCell(c);
      }).toList();

      /// 固定宽度不能太大
      RenderBox boxRenderObject = context.findRenderObject();
      if (boxRenderObject != null &&
          null != boxRenderObject.constraints &&
          boxRenderObject.constraints.maxWidth - defaultColumnWidth <
              stickyWidth) {
        print('固定表格列越界了，暂时不支持渲染...');
        return new Container();
      }

      /// 非固定的列
      List<Widget> unStickyColumnWidgets =
          unStickyColumns.map((ColumnsProps c) => getCell(c)).toList();

      return new Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
        new Container(
//          color: Colors.grey,
          child: new Row(
//            mainAxisSize: MainAxisSize.min,
            children: stickyColumnWidgets,
          ),
        ),
        Expanded(
            child: new Container(
//                color: Colors.blue,
                child: new SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: widget.scrollController,
                    child: new Row(
//                        mainAxisSize: MainAxisSize.min,
//                          crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: unStickyColumnWidgets))))
      ]);
    });
  }
}

/// 表头
class TableHeader extends StatefulWidget {
  final ScrollController scrollController;

  /// 固定列的数量
  final int stickyColumnCount;

  /// 所有列的配置
  final List<ColumnsProps> columns;

  /// 背景色
  final Color backgroundColor;

  final bool showBorder;

  const TableHeader(
      {Key key,
      this.scrollController,
      this.stickyColumnCount = 0,
      this.columns,
      this.backgroundColor,
      this.showBorder = false})
      : super(key: key);

  @override
  _TableHeaderState createState() => _TableHeaderState();
}

class _TableHeaderState extends State<TableHeader> {
  double maxHeight = 0.0;

  bool mounted = false;

  @override
  void initState() {
    super.initState();

    mounted = true;
  }

  @override
  void didUpdateWidget(TableHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 如果数据没变化则不更新
    if (oldWidget.columns == widget.columns) {
      return;
    }

    /// 数据变化后重新计算最大高度
    maxHeight = 0;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    mounted = false;

    super.dispose();
  }

  /// 单元格
  Widget getCell(ColumnsProps c) {
    return TableCell(
      render: Text(c.title),
      backgroundColor: c.headColor,
      width: c.width > 0 ? c.width : defaultColumnWidth,
      showBorder: widget.showBorder,
      alignment: c.alignment,
      height: maxHeight > 0 ? maxHeight : null,
      onSized: (size) {
        if (maxHeight > size.height || maxHeight == size.height) {
          return;
        }

        /// 取出每行最大高度
        maxHeight = size.height;

        /// 重新绘制每个单元格的高度
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (null == widget.columns || widget.columns.length == 0) {
      return new Container();
    }

    int _stickyColumnCount =
        min(widget.stickyColumnCount, widget.columns.length);

    /// 固定的列
    List<ColumnsProps> stickyColumnProps = _stickyColumnCount > 0
        ? widget.columns.sublist(0, _stickyColumnCount)
        : [];
    double stickyWidth = 0.0;
    List<Widget> stickyColumnWidgets = stickyColumnProps.map((ColumnsProps c) {
      stickyWidth += c.width > 0 ? c.width : defaultColumnWidth;
      return getCell(c);
    }).toList();

    /// 固定宽度不能太大
    RenderBox boxRenderObject = context.findRenderObject();
    if (boxRenderObject != null &&
        null != boxRenderObject.constraints &&
        boxRenderObject.constraints.maxWidth - defaultColumnWidth <
            stickyWidth) {
      print('固定表格列越界了，暂时不支持渲染...');
      return new Container();
    }

    /// 不固定的列
    List<ColumnsProps> unStickyColumns = _stickyColumnCount > 0
        ? widget.columns.sublist(_stickyColumnCount)
        : widget.columns;
    List<Widget> unStickyColumnWidgets =
        unStickyColumns.map((ColumnsProps c) => getCell(c)).toList();

    return new Container(
      child: new Row(
          children: <Widget>[]
            ..addAll(stickyColumnWidgets)
            ..add(Expanded(
                child: new SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: widget.scrollController,
                    child: new Row(children: unStickyColumnWidgets))))),
      color: widget.backgroundColor ?? defaultHeaderBackgroundColor,
    );
  }
}

/// 单元格控件
class TableCell extends StatelessWidget {
  final double width;

  final Alignment alignment;

  final bool showBorder;

  final ValueChanged<Size> onSized;

  final Widget render;

  final double height;

  final Color backgroundColor;

  const TableCell(
      {Key key,
      this.width = 0.0,
      this.alignment = Alignment.centerLeft,
      this.showBorder = false,
      this.onSized,
      this.render,
      this.height,
      this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBoxRed = context.findRenderObject();
      if (null != renderBoxRed && null != onSized) {
        onSized(renderBoxRed.size);
      }
    });
    return new Container(
      height: (height ?? 0.0) > 0.0 ? height : null,
      width: width > 0.0 ? width : defaultColumnWidth,
      padding: EdgeInsets.all(defaultPadding),
      alignment: alignment ?? Alignment.centerLeft,
      decoration: new BoxDecoration(
          color: backgroundColor,
          border: showBorder
              ? new Border.all(color: Colors.black12, width: 1.0)
              : null),
      child: this.render,
    );
    ;
  }
}

///
/// 固定头部控件，参考https://github.com/fluttercommunity/flutter_sticky_headers
///
class StickyHeader extends MultiChildRenderObjectWidget {
  ///
  /// sticky效果的头部内容
  ///
  final Widget header;

  ///
  /// 内容
  ///
  final Widget content;

  StickyHeader({
    Key key,
    @required this.header,
    @required this.content,
  }) : super(
          key: key,
          // Note: The order of the children must be preserved for the RenderObject.
          children: [content, header],
        );

  @override
  StickyHeaderRender createRenderObject(BuildContext context) {
    var scrollable = Scrollable.of(context);
    assert(scrollable != null);
    return new StickyHeaderRender(
      scrollable: scrollable,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, StickyHeaderRender renderObject) {
    renderObject.._scrollable = Scrollable.of(context);
  }
}

/// StickyHeader渲染器
class StickyHeaderRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  // short-hand to access the child RenderObjects

  ScrollableState _scrollable;

  RenderBox get _headerBox => lastChild;

  RenderBox get _contentBox => firstChild;

  StickyHeaderRender({
    @required ScrollableState scrollable,
  }) : _scrollable = scrollable;

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position?.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position?.removeListener(markNeedsLayout);
    super.detach();
  }

  set scrollableX(ScrollableState newValue) {
    assert(newValue != null);
    if (_scrollable == newValue) {
      return;
    }
    final ScrollableState oldValue = _scrollable;
    _scrollable = newValue;
    markNeedsLayout();
    if (attached) {
      oldValue.position?.removeListener(markNeedsLayout);
      newValue.position?.addListener(markNeedsLayout);
    }
  }

  @override
  void performLayout() {
    // ensure we have header and content boxes
    assert(childCount == 2);

    // layout both header and content widget
    final childConstraints = constraints.loosen();
    print(childConstraints);
    _headerBox.layout(childConstraints, parentUsesSize: true);
    _contentBox.layout(childConstraints, parentUsesSize: true);

    final headerHeight = _headerBox.size.height;
    final contentHeight = _contentBox.size.height;

    // determine size of ourselves based on content widget
    final width = max(constraints.minWidth, _contentBox.size.width);

    /// header与content并列
    final height = max(constraints.minHeight, headerHeight + contentHeight);

    size = new Size(width, height);
    assert(size.width == constraints.constrainWidth(width));
    assert(size.height == constraints.constrainHeight(height));
    assert(size.isFinite);

    // place content underneath header
    final contentParentData =
        _contentBox.parentData as MultiChildLayoutParentData;

    /// 固定并列显示header
    contentParentData.offset = new Offset(0.0, headerHeight);

    // determine by how much the header should be stuck to the top
    final double stuckXOffset = determineStuckXOffset();

    // place header over content relative to scroll offset
    final double maxOffset = height - headerHeight;
    final headerParentData =
        _headerBox.parentData as MultiChildLayoutParentData;
    headerParentData.offset =
        new Offset(0.0, max(0.0, min(-stuckXOffset, maxOffset)));
//    print(headerParentData.offset);
  }

  double determineStuckXOffset() {
    final scrollBox = _scrollable.context.findRenderObject();
    if (scrollBox?.attached ?? false) {
      try {
        return localToGlobal(Offset.zero, ancestor: scrollBox).dy;
      } catch (e) {
        // ignore and fall-through and return 0.0
      }
    }
    return 0.0;
  }

  @override
  void setupParentData(RenderObject child) {
    super.setupParentData(child);
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = new MultiChildLayoutParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _contentBox.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _contentBox.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return (_headerBox.getMinIntrinsicHeight(width) +
        _contentBox.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return (_headerBox.getMaxIntrinsicHeight(width) +
        _contentBox.getMaxIntrinsicHeight(width));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
