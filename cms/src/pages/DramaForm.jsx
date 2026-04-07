import { useState } from 'react';
import { Form, Input, Select, Button, Card, Space, InputNumber, Typography, message, Divider } from 'antd';
import { PlusOutlined, DeleteOutlined, VideoCameraOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { createDrama } from '../api';

const { Title, Text } = Typography;
const { TextArea } = Input;

const CATEGORIES = [
  { value: 'male', label: '男频' },
  { value: 'female', label: '女频' },
  { value: 'mystery', label: '悬疑' },
  { value: 'scifi', label: '科幻' },
  { value: 'ancient', label: '古风' },
  { value: 'urban', label: '都市' },
  { value: 'comedy', label: '搞笑' },
  { value: 'romance', label: '甜宠' },
];

export default function DramaForm() {
  const [form] = Form.useForm();
  const [episodes, setEpisodes] = useState([{ ep: 1, video: '', duration: 90 }]);
  const [submitting, setSubmitting] = useState(false);
  const navigate = useNavigate();

  const addEpisode = () => {
    const next = episodes.length + 1;
    setEpisodes([...episodes, { ep: next, video: '', duration: 90 }]);
  };

  const removeEpisode = (idx) => {
    const updated = episodes.filter((_, i) => i !== idx).map((e, i) => ({ ...e, ep: i + 1 }));
    setEpisodes(updated);
  };

  const updateEpisode = (idx, field, value) => {
    const updated = episodes.map((e, i) => i === idx ? { ...e, [field]: value } : e);
    setEpisodes(updated);
  };

  const onFinish = async (values) => {
    const validEps = episodes.filter((e) => e.video.trim());
    if (validEps.length === 0) {
      message.warning('请至少添加一集视频');
      return;
    }
    setSubmitting(true);
    try {
      const tags = (values.tags || '').split(/[,，\s]+/).filter(Boolean);
      await createDrama({
        title: values.title,
        description: values.description || '',
        category: values.category,
        tags,
        cover: values.cover || '',
        episodes: validEps,
      });
      message.success('创建成功');
      navigate('/dramas');
    } catch (e) {
      message.error(e.message || '创建失败');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={{ maxWidth: 800 }}>
      <Title level={4}>新建剧集</Title>
      <Card>
        <Form form={form} layout="vertical" onFinish={onFinish}>
          <Form.Item name="title" label="标题" rules={[{ required: true, message: '请输入标题' }]}>
            <Input placeholder="重生归来：豪门逆袭" maxLength={64} size="large" />
          </Form.Item>

          <Form.Item name="category" label="分类" rules={[{ required: true, message: '请选择分类' }]}>
            <Select options={CATEGORIES} placeholder="选择分类" size="large" />
          </Form.Item>

          <Form.Item name="tags" label="标签（逗号分隔）">
            <Input placeholder="重生, 逆袭, 豪门" />
          </Form.Item>

          <Form.Item name="description" label="简介">
            <TextArea rows={3} placeholder="一句话简介" maxLength={256} showCount />
          </Form.Item>

          <Form.Item name="cover" label="封面 OSS Key（可选）">
            <Input placeholder="covers/drama_001.jpg" />
          </Form.Item>

          <Divider>分集管理</Divider>

          <div style={{ marginBottom: 16 }}>
            <Text type="secondary">添加每一集的视频 OSS Key 或完整 URL</Text>
          </div>

          {episodes.map((ep, idx) => (
            <Space key={idx} style={{ display: 'flex', marginBottom: 8 }} align="start">
              <Text style={{ width: 50, lineHeight: '32px' }}>第{ep.ep}集</Text>
              <Input
                value={ep.video}
                onChange={(e) => updateEpisode(idx, 'video', e.target.value)}
                placeholder="video_key 或 https://..."
                style={{ width: 360 }}
              />
              <InputNumber
                value={ep.duration}
                onChange={(v) => updateEpisode(idx, 'duration', v)}
                min={1}
                max={600}
                addonAfter="秒"
                style={{ width: 120 }}
              />
              {episodes.length > 1 && (
                <Button icon={<DeleteOutlined />} danger type="text"
                  onClick={() => removeEpisode(idx)} />
              )}
            </Space>
          ))}

          <Button type="dashed" block icon={<PlusOutlined />} onClick={addEpisode}
            style={{ marginBottom: 24 }}>
            添加一集
          </Button>

          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit" loading={submitting}
                icon={<VideoCameraOutlined />} size="large">
                创建剧集
              </Button>
              <Button onClick={() => navigate('/dramas')} size="large">取消</Button>
            </Space>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
}
