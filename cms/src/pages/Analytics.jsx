import { useState, useEffect } from 'react';
import { Row, Col, Card, Statistic, Typography, Table, Tag, Space, message } from 'antd';
import {
  EyeOutlined,
  PlayCircleOutlined,
  ThunderboltOutlined,
  RiseOutlined,
  LikeOutlined,
  ShareAltOutlined,
} from '@ant-design/icons';
import { getAnalytics } from '../api';

const { Title, Text } = Typography;

const EVENT_LABELS = {
  app_launch: { label: '启动', icon: <EyeOutlined />, color: '#1890ff' },
  drama_click: { label: '点击剧集', icon: <EyeOutlined />, color: '#52c41a' },
  episode_play: { label: '开始播放', icon: <PlayCircleOutlined />, color: '#ff4d4f' },
  episode_complete: { label: '完播', icon: <ThunderboltOutlined />, color: '#ffd666' },
  auto_next: { label: '自动连播', icon: <RiseOutlined />, color: '#13c2c2' },
  ad_interstitial_show: { label: '插屏广告', icon: <EyeOutlined />, color: '#fa8c16' },
  ad_reward_finish: { label: '激励完成', icon: <LikeOutlined />, color: '#eb2f96' },
  unlock_success: { label: '解锁成功', icon: <LikeOutlined />, color: '#722ed1' },
  sign_in: { label: '签到', icon: <LikeOutlined />, color: '#52c41a' },
  share_drama: { label: '分享', icon: <ShareAltOutlined />, color: '#1890ff' },
};

export default function Analytics() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const d = await getAnalytics();
        setData(d);
      } catch (e) {
        message.error(e.message || '获取数据失败');
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const metrics = data?.metrics || {};
  const total = data?.total || {};
  const today = data?.today || {};

  // 指标卡
  const metricCards = [
    {
      title: '完播率',
      value: `${(metrics.completionRate * 100 || 0).toFixed(1)}%`,
      desc: '= 完播次数 / 播放次数',
      color: '#ff4d4f',
    },
    {
      title: '连播率',
      value: `${(metrics.autoNextRate * 100 || 0).toFixed(1)}%`,
      desc: '= 自动连播 / 完播次数',
      color: '#ffd666',
    },
    {
      title: '广告转化率',
      value: `${(metrics.adConversionRate * 100 || 0).toFixed(1)}%`,
      desc: '= 解锁成功 / 激励完成',
      color: '#722ed1',
    },
  ];

  // 事件明细表
  const tableData = Object.keys(EVENT_LABELS).map((event) => ({
    key: event,
    event,
    label: EVENT_LABELS[event]?.label || event,
    total: total[event] || 0,
    today: today[event] || 0,
  }));

  // 每日趋势表
  const dailyDates = Object.keys(data?.daily || {}).sort().reverse();
  const dailyColumns = [
    { title: '日期', dataIndex: 'date', width: 120 },
    ...Object.keys(EVENT_LABELS).map((e) => ({
      title: EVENT_LABELS[e]?.label || e,
      dataIndex: e,
      width: 80,
      render: (v) => v || '-',
    })),
  ];
  const dailyData = dailyDates.map((date) => {
    const row = { key: date, date };
    const dayEvents = data?.daily?.[date] || {};
    Object.keys(EVENT_LABELS).forEach((e) => {
      row[e] = dayEvents[e] || 0;
    });
    return row;
  });

  return (
    <div>
      <Title level={4}>埋点看板</Title>

      {/* 衍生指标 */}
      <Row gutter={[16, 16]} style={{ marginBottom: 24 }}>
        {metricCards.map((m) => (
          <Col xs={24} sm={8} key={m.title}>
            <Card loading={loading} style={{ borderRadius: 16, border: 'none' }}>
              <Statistic
                title={<Text style={{ color: '#999' }}>{m.title}</Text>}
                value={m.value}
                valueStyle={{ color: m.color, fontSize: 32, fontWeight: 'bold' }}
              />
              <Text type="secondary" style={{ fontSize: 12 }}>{m.desc}</Text>
            </Card>
          </Col>
        ))}
      </Row>

      {/* 事件总量 + 今日 */}
      <Card title="事件统计" style={{ borderRadius: 16, marginBottom: 24 }} loading={loading}>
        <Table
          rowKey="key"
          dataSource={tableData}
          pagination={false}
          size="small"
          columns={[
            {
              title: '事件',
              dataIndex: 'label',
              render: (text, record) => (
                <Space>
                  <Tag color={EVENT_LABELS[record.event]?.color}>{text}</Tag>
                  <Text type="secondary" style={{ fontSize: 11 }}>{record.event}</Text>
                </Space>
              ),
            },
            {
              title: '总量',
              dataIndex: 'total',
              sorter: (a, b) => a.total - b.total,
              render: (v) => <span style={{ fontWeight: 600 }}>{v}</span>,
            },
            {
              title: '今日',
              dataIndex: 'today',
              render: (v) => v > 0 ? <Tag color="green">+{v}</Tag> : '-',
            },
          ]}
        />
      </Card>

      {/* 每日趋势 */}
      {dailyData.length > 0 && (
        <Card title="每日趋势（最近 7 天）" style={{ borderRadius: 16 }} loading={loading}>
          <Table
            rowKey="key"
            dataSource={dailyData}
            columns={dailyColumns}
            pagination={false}
            size="small"
            scroll={{ x: 900 }}
          />
        </Card>
      )}
    </div>
  );
}
