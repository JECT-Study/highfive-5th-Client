import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { Dialog } from './Dialog';

afterEach(cleanup);

function renderDialog() {
  const onConfirm = vi.fn();
  const onCancel = vi.fn();
  render(
    <Dialog
      open
      title="신청을 취소할까요?"
      confirmLabel="취소하기"
      cancelLabel="닫기"
      onConfirm={onConfirm}
      onCancel={onCancel}
    />,
  );
  return { onConfirm, onCancel };
}

describe('Dialog', () => {
  it('확인을 누르면 onConfirm만 부른다', () => {
    const { onConfirm, onCancel } = renderDialog();

    fireEvent.click(screen.getByRole('button', { name: '취소하기' }));

    expect(onConfirm).toHaveBeenCalledTimes(1);
    expect(onCancel).not.toHaveBeenCalled();
  });

  it('닫기, 바깥 누르기, Esc는 onCancel을 부르고 제목으로 이름이 붙는다', () => {
    const { onCancel } = renderDialog();
    const dialog = screen.getByRole('dialog', { name: '신청을 취소할까요?' });

    fireEvent.click(screen.getByRole('button', { name: '닫기' }));
    fireEvent.click(dialog.parentElement!);
    fireEvent.keyDown(document, { key: 'Escape' });

    expect(onCancel).toHaveBeenCalledTimes(3);
  });

  it('open이 false면 그리지 않는다', () => {
    render(
      <Dialog
        open={false}
        title="t"
        confirmLabel="확인"
        onConfirm={() => {}}
        onCancel={() => {}}
      />,
    );

    expect(screen.queryByRole('dialog')).toBeNull();
  });
});
