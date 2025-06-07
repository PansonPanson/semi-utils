#!/bin/bash

EXIFTOOL_FILE_NAME="Image-ExifTool-12.92.tar.gz"
EXIFTOOL_FILE_DOWNLOAD_URL="http://file.lsvm.xyz/Image-ExifTool-12.92.tar.gz"

if [ -f "inited" ]; then
  echo "已完成初始化, 开始运行(如需重新初始化, 请删除 inited 文件)"
  exit 0
fi

# 下载文件
curl -O -L $EXIFTOOL_FILE_DOWNLOAD_URL

# 测试 gzip 压缩的有效性
if ! gzip -t "$EXIFTOOL_FILE_NAME"; then
    echo "下载的 ExifTool gzip 压缩文件格式不正确"
    echo "请检查 url 的有效性： $EXIFTOOL_FILE_DOWNLOAD_URL"
    echo "当前下载的 ExifTool gzip 的格式为："
    file "$EXIFTOOL_FILE_NAME"
    echo "安装未完成，初始化脚本中断"
    exit 1
fi

# 创建目录
mkdir -p ./exiftool

# 解压文件
tar -xzf "$EXIFTOOL_FILE_NAME" -C ./exiftool --strip-components=1

# 删除压缩包
rm "$EXIFTOOL_FILE_NAME"

# 获取 Python 版本
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")

# 对于Python 3.13+直接安装兼容版本
if [[ "$PYTHON_VERSION" > "3.12" ]]; then
  echo "检测到 Python $PYTHON_VERSION，安装兼容的 Pillow 和其他依赖"
  
  # 创建临时requirements文件排除Pillow
  grep -v 'pillow' requirements.txt > temp_requirements.txt
  echo "tqdm" >> temp_requirements.txt  # 确保tqdm被安装
  
  # 安装依赖
  pip3 install -r temp_requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
  pip3 install pillow==10.4.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
  
  # 清理临时文件
  rm temp_requirements.txt
else
  echo "使用默认依赖安装"
  pip3 install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
fi

# 初始化完成
touch inited
echo "初始化完成, inited 文件已生成, 如需重新初始化, 请删除 inited 文件"
echo "已安装的Python包:"
pip3 list | grep -E "pillow|tqdm"
exit 0
