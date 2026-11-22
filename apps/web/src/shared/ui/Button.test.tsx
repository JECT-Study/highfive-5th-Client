import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { Button } from './Button';

afterEach(cleanup);

describe('Button', () => {
  it('누르면 onClick을 한 번 부르고, 기본 type은 button이다', () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick}>다음</Button>);

    const button = screen.getByRole('button', { name: '다음' });
    fireEvent.click(button);

    expect(onClick).toHaveBeenCalledTimes(1);
    expect(button.getAttribute('type')).toBe('button');
  });

  it('로딩 중에는 이름을 유지한 채 비활성·busy가 되어 눌리지 않는다', () => {
    const onClick = vi.fn();
    render(
      <Button onClick={onClick} loading>
        다음
      </Button>,
    );

    const button = screen.getByRole('button', { name: '다음' }) as HTMLButtonElement;
    fireEvent.click(button);

    expect(onClick).not.toHaveBeenCalled();
    expect(button.disabled).toBe(true);
    expect(button.getAttribute('aria-busy')).toBe('true');
  });
});
