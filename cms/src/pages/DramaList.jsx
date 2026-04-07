import { useState, useEffect } from 'react';
import { Table, Input, Select, Tag, Space, Typography, message } from 'antd';
import { SearchOutlined } from '@ant-design/icons';
import { getDramaFeed, searchDramas } from '../api';

const { Title } = Typography;

const CATEGORIES = [
  { value: '', label: '全部' },
  { value: 'male', label: '男频' },
  { value: 'female', label: '女频' },
  { value: 'mystery', label: '悬疑' },
  { value: 'scifi', label: '科幻' },
  { value: 'ancient', label: '古风' },
  { value: 'urban', label: '都市' },
];

const TAG_COLORS = ['red', 'volcano', 'orange', 'gold', 'cyan', 'blue', 'purple', 'magenta'];

export default function DramaList() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [category, setCategory] = useState('');
  const [searchQ, setSearchQ] = useState('');

  const load = async () => {
    setLoading(true);
    try {
      if (searchQ.trim()) {
        const list = await searchDramas(searchQ.trim());
        setData(list || []);
      } else {
        const result = await getDramaFeed(1, 100, category);
        setData(result?.list || []);
      }
    } catch (e) {
      message.error(e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [category]);

  const handleSearch = () => { load(); };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      width: 70,
      sorter: (a, b) => a.id - b.id,
    },
    {
      title: '标题',
      dataIndex: 'title',
      ellipsis: true,
      render: (text) => <span style={{ fontWeight: 600 }}>{text}</span>,
    },
    {
      title: '标签',
      dataIndex: 'tags',
      render: (tags) => (
        <Space size={4} wrap>
          {(tags || []).map((t, i) => (
            <Tag key={t} color={TAG_COLORS[i % TAG_COLORS.length]}>{t}</Tag>
          ))}
        </Space>
      ),
    },
    {
      title: '总集数',
      dataIndex: 'episodeCount',
      width: 80,
      sorter: (a, b) => a.episodeCount - b.episodeCount,
    },
    {
      title: '更新至',
      dataIndex: 'updatedTo',
      width: 80,
    },
    {
      title: '热度',
      dataIndex: 'heat',
      width: 100,
      sorter: (a, b) => a.heat - b.heat,
      render: (v) => v >= 10000 ? `${(v / 10000).toFixed(1)}w` : v,
    },
  ];

  return (
    <div>
      <Title level={4}>剧集管理</Title>
      <Space style={{ marginBottom: 16 }} wrap>
        <Input.Search
          placeholder="搜索标题 / 标签"
          value={searchQ}
          onChange={(e) => setSearchQ(e.target.value)}
          onSearch={handleSearch}
          allowClear
          style={{ width: 280 }}
          prefix={<SearchOutlined />}
        />
        <Select
          value={category}
          onChange={(v) => { setSearchQ(''); setCategory(v); }}
          options={CATEGORIES}
          style={{ width: 120 }}
        />
      </Space>
      <Table
        rowKey="id"
        columns={columns}
        dataSource={data}
        loading={loading}
        pagination={{ pageSize: 20, showSizeChanger: false, showTotal: (t) => `共 ${t} 部` }}
        size="middle"
      />
    </div>
  );
}
